const { getPool, sql } = require('../config/database');

// GET /api/charges  (syndic: all charges for their buildings)
const getAllCharges = async (req, res, next) => {
  try {
    const pool = await getPool();
    const { statut, immeubleId, page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;

    let query = `
      SELECT c.*, i.nom AS immeubleNom, 
             p.nom AS proprietaireNom, p.prenom AS proprietairePrenom
      FROM Charges c
      INNER JOIN Immeubles i ON c.immeubleId = i.id
      LEFT JOIN  Proprietaires p ON c.proprietaireId = p.id
    `;
    const conditions = [];

    // Syndic sees only their buildings
    if (req.user.role === 'syndic') {
      const syndicResult = await pool.request()
        .input('userId', sql.Int, req.user.id)
        .query('SELECT id FROM Syndics WHERE userId = @userId');
      const syndicId = syndicResult.recordset[0]?.id;
      conditions.push(`i.syndicId = ${syndicId}`);
    }

    // Proprietaire sees only their own charges
    if (req.user.role === 'proprietaire') {
      const propResult = await pool.request()
        .input('userId', sql.Int, req.user.id)
        .query('SELECT id FROM Proprietaires WHERE userId = @userId');
      const propId = propResult.recordset[0]?.id;
      conditions.push(`c.proprietaireId = ${propId}`);
    }

    if (statut) conditions.push(`c.statut = '${statut}'`);
    if (immeubleId) conditions.push(`c.immeubleId = ${immeubleId}`);
    if (conditions.length) query += ' WHERE ' + conditions.join(' AND ');

    query += ` ORDER BY c.dateEcheance DESC
               OFFSET ${offset} ROWS FETCH NEXT ${limit} ROWS ONLY`;

    const result = await pool.request().query(query);
    res.json({ success: true, data: result.recordset, page: Number(page), limit: Number(limit) });
  } catch (err) {
    next(err);
  }
};

// GET /api/charges/:id
const getChargeById = async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query(`
        SELECT c.*, i.nom AS immeubleNom,
               p.nom AS proprietaireNom, p.prenom AS proprietairePrenom
        FROM Charges c
        INNER JOIN Immeubles i ON c.immeubleId = i.id
        LEFT JOIN  Proprietaires p ON c.proprietaireId = p.id
        WHERE c.id = @id
      `);

    if (!result.recordset[0]) {
      return res.status(404).json({ success: false, message: 'Charge not found.' });
    }
    res.json({ success: true, data: result.recordset[0] });
  } catch (err) {
    next(err);
  }
};

// POST /api/charges  (syndic only)
const createCharge = async (req, res, next) => {
  try {
    const { immeubleId, proprietaireId, description, montant, dateEcheance, type } = req.body;

    if (!immeubleId || !description || !montant || !dateEcheance) {
      return res.status(400).json({ success: false, message: 'Missing required fields.' });
    }

    const pool = await getPool();
    const result = await pool.request()
      .input('immeubleId',     sql.Int,          immeubleId)
      .input('proprietaireId', sql.Int,          proprietaireId || null)
      .input('description',    sql.NVarChar,     description)
      .input('montant',        sql.Decimal(10,2),montant)
      .input('dateEcheance',   sql.Date,         dateEcheance)
      .input('type',           sql.NVarChar,     type || null)
      .query(`
        INSERT INTO Charges (immeubleId, proprietaireId, description, montant, dateEcheance, type)
        OUTPUT INSERTED.*
        VALUES (@immeubleId, @proprietaireId, @description, @montant, @dateEcheance, @type)
      `);

    res.status(201).json({ success: true, message: 'Charge created.', data: result.recordset[0] });
  } catch (err) {
    next(err);
  }
};

// PUT /api/charges/:id  (syndic only)
const updateCharge = async (req, res, next) => {
  try {
    const { description, montant, dateEcheance, statut, type } = req.body;
    const pool = await getPool();

    await pool.request()
      .input('id',           sql.Int,          req.params.id)
      .input('description',  sql.NVarChar,     description)
      .input('montant',      sql.Decimal(10,2),montant)
      .input('dateEcheance', sql.Date,         dateEcheance)
      .input('statut',       sql.NVarChar,     statut)
      .input('type',         sql.NVarChar,     type || null)
      .query(`
        UPDATE Charges 
        SET description=@description, montant=@montant, dateEcheance=@dateEcheance,
            statut=@statut, type=@type, updatedAt=GETDATE()
        WHERE id=@id
      `);

    res.json({ success: true, message: 'Charge updated.' });
  } catch (err) {
    next(err);
  }
};

// DELETE /api/charges/:id  (syndic only)
const deleteCharge = async (req, res, next) => {
  try {
    const pool = await getPool();
    await pool.request()
      .input('id', sql.Int, req.params.id)
      .query('DELETE FROM Charges WHERE id = @id');

    res.json({ success: true, message: 'Charge deleted.' });
  } catch (err) {
    next(err);
  }
};

// GET /api/charges/impayes/dashboard  (syndic only)
const getImpayesDashboard = async (req, res, next) => {
  try {
    const pool = await getPool();

    const syndicResult = await pool.request()
      .input('userId', sql.Int, req.user.id)
      .query('SELECT id FROM Syndics WHERE userId = @userId');
    const syndicId = syndicResult.recordset[0]?.id;

    const result = await pool.request()
      .input('syndicId', sql.Int, syndicId)
      .query(`
        SELECT 
          COUNT(*) AS totalImpayes,
          SUM(c.montant) AS montantTotal,
          i.nom AS immeubleNom,
          i.id AS immeubleId
        FROM Charges c
        INNER JOIN Immeubles i ON c.immeubleId = i.id
        WHERE i.syndicId = @syndicId
          AND c.statut IN ('en_attente', 'en_retard')
        GROUP BY i.id, i.nom
        ORDER BY montantTotal DESC
      `);

    const totals = await pool.request()
      .input('syndicId', sql.Int, syndicId)
      .query(`
        SELECT 
          COUNT(*) AS totalCharges,
          SUM(CASE WHEN statut='paye' THEN montant ELSE 0 END) AS totalPercu,
          SUM(CASE WHEN statut IN('en_attente','en_retard') THEN montant ELSE 0 END) AS totalImpaye
        FROM Charges c
        INNER JOIN Immeubles i ON c.immeubleId = i.id
        WHERE i.syndicId = @syndicId
      `);

    res.json({
      success: true,
      data: {
        summary: totals.recordset[0],
        parImmeuble: result.recordset,
      },
    });
  } catch (err) {
    next(err);
  }
};

module.exports = { getAllCharges, getChargeById, createCharge, updateCharge, deleteCharge, getImpayesDashboard };
