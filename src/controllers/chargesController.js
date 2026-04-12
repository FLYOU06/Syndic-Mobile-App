const { getPool, sql } = require('../config/database');
const notificationService = require('../services/notificationService');

// GET /api/charges
const getAllCharges = async (req, res, next) => {
  try {
    const pool = await getPool();
    const { statut, immeubleId, page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;
    const conditions = [];

    if (req.user.role === 'syndic') {
      const r = await pool.request()
        .input('userId', sql.Int, req.user.id)
        .query('SELECT id FROM Syndics WHERE userId = @userId');
      conditions.push(`i.syndicId = ${r.recordset[0]?.id}`);
    }

    if (req.user.role === 'proprietaire' || req.user.role === 'locataire') {
      const r = await pool.request()
        .input('userId', sql.Int, req.user.id)
        .query('SELECT id FROM Habitants WHERE userId = @userId');
      conditions.push(`c.habitantId = ${r.recordset[0]?.id}`);
    }

    if (statut)     conditions.push(`c.statut = '${statut}'`);
    if (immeubleId) conditions.push(`c.immeubleId = ${immeubleId}`);

    const where = conditions.length ? 'WHERE ' + conditions.join(' AND ') : '';

    const result = await pool.request().query(`
      SELECT c.*,
             i.nom AS immeubleNom,
             h.nom AS habitantNom, h.prenom AS habitantPrenom, h.type AS habitantType
      FROM Charges c
      INNER JOIN Immeubles i ON c.immeubleId = i.id
      LEFT JOIN  Habitants h ON c.habitantId  = h.id
      ${where}
      ORDER BY c.dateEcheance DESC
      OFFSET ${offset} ROWS FETCH NEXT ${limit} ROWS ONLY
    `);

    res.json({ success: true, data: result.recordset, page: Number(page), limit: Number(limit) });
  } catch (err) { next(err); }
};

// GET /api/charges/:id
const getChargeById = async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query(`
        SELECT c.*,
               i.nom AS immeubleNom,
               h.nom AS habitantNom, h.prenom AS habitantPrenom, h.type AS habitantType
        FROM Charges c
        INNER JOIN Immeubles i ON c.immeubleId = i.id
        LEFT JOIN  Habitants h ON c.habitantId  = h.id
        WHERE c.id = @id
      `);

    if (!result.recordset[0])
      return res.status(404).json({ success: false, message: 'Charge not found.' });

    res.json({ success: true, data: result.recordset[0] });
  } catch (err) { next(err); }
};

// POST /api/charges  (syndic only)
const createCharge = async (req, res, next) => {
  try {
    const { immeubleId, habitantId, nom, description, montant, dateEcheance, type } = req.body;

    if (!immeubleId || !nom || !montant || !dateEcheance)
      return res.status(400).json({ success: false, message: 'immeubleId, nom, montant and dateEcheance are required.' });

    const pool = await getPool();
    const result = await pool.request()
      .input('immeubleId',  sql.Int,           immeubleId)
      .input('habitantId',  sql.Int,           habitantId  || null)
      .input('nom',         sql.NVarChar,      nom)
      .input('description', sql.NVarChar,      description || null)
      .input('montant',     sql.Decimal(10,2), montant)
      .input('dateEcheance',sql.Date,          dateEcheance)
      .input('type',        sql.NVarChar,      type        || null)
      .query(`
        INSERT INTO Charges (immeubleId,habitantId,nom,description,montant,dateEcheance,type)
        OUTPUT INSERTED.*
        VALUES (@immeubleId,@habitantId,@nom,@description,@montant,@dateEcheance,@type)
      `);

    // Notify the habitant
    if (habitantId) {
      const userRes = await pool.request()
        .input('id', sql.Int, habitantId)
        .query('SELECT userId FROM Habitants WHERE id = @id');
      if (userRes.recordset[0]) {
        await notificationService.create(
          userRes.recordset[0].userId,
          'Nouvelle charge',
          `Une nouvelle charge "${nom}" de ${montant} MAD a été ajoutée. Échéance : ${dateEcheance}.`,
          'charge'
        );
      }
    }

    res.status(201).json({ success: true, message: 'Charge created.', data: result.recordset[0] });
  } catch (err) { next(err); }
};

// PUT /api/charges/:id  (syndic only)
const updateCharge = async (req, res, next) => {
  try {
    const { nom, description, montant, dateEcheance, statut, type } = req.body;
    const pool = await getPool();
    await pool.request()
      .input('id',          sql.Int,           req.params.id)
      .input('nom',         sql.NVarChar,      nom)
      .input('description', sql.NVarChar,      description || null)
      .input('montant',     sql.Decimal(10,2), montant)
      .input('dateEcheance',sql.Date,          dateEcheance)
      .input('statut',      sql.NVarChar,      statut)
      .input('type',        sql.NVarChar,      type || null)
      .query(`
        UPDATE Charges
        SET nom=@nom, description=@description, montant=@montant,
            dateEcheance=@dateEcheance, statut=@statut, type=@type, updatedAt=GETDATE()
        WHERE id=@id
      `);
    res.json({ success: true, message: 'Charge updated.' });
  } catch (err) { next(err); }
};

// DELETE /api/charges/:id  (syndic only)
const deleteCharge = async (req, res, next) => {
  try {
    const pool = await getPool();
    await pool.request()
      .input('id', sql.Int, req.params.id)
      .query('DELETE FROM Charges WHERE id = @id');
    res.json({ success: true, message: 'Charge deleted.' });
  } catch (err) { next(err); }
};

// GET /api/charges/impayes/dashboard  (syndic only)
const getImpayesDashboard = async (req, res, next) => {
  try {
    const pool = await getPool();
    const syndicRes = await pool.request()
      .input('userId', sql.Int, req.user.id)
      .query('SELECT id FROM Syndics WHERE userId = @userId');
    const syndicId = syndicRes.recordset[0]?.id;

    const parImmeuble = await pool.request()
      .input('syndicId', sql.Int, syndicId)
      .query(`
        SELECT i.id AS immeubleId, i.nom AS immeubleNom,
               COUNT(*)       AS totalImpayes,
               SUM(c.montant) AS montantTotal
        FROM Charges c
        INNER JOIN Immeubles i ON c.immeubleId = i.id
        WHERE i.syndicId = @syndicId
          AND c.statut IN ('en_attente','en_retard')
        GROUP BY i.id, i.nom
        ORDER BY montantTotal DESC
      `);

    const totals = await pool.request()
      .input('syndicId', sql.Int, syndicId)
      .query(`
        SELECT
          COUNT(*) AS totalCharges,
          SUM(CASE WHEN c.statut='paye'                       THEN c.montant ELSE 0 END) AS totalPercu,
          SUM(CASE WHEN c.statut IN('en_attente','en_retard') THEN c.montant ELSE 0 END) AS totalImpaye
        FROM Charges c
        INNER JOIN Immeubles i ON c.immeubleId = i.id
        WHERE i.syndicId = @syndicId
      `);

    res.json({ success: true, data: { summary: totals.recordset[0], parImmeuble: parImmeuble.recordset } });
  } catch (err) { next(err); }
};

module.exports = { getAllCharges, getChargeById, createCharge, updateCharge, deleteCharge, getImpayesDashboard };