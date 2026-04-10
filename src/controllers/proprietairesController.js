const { getPool, sql } = require('../config/database');

// GET /api/proprietaires  (syndic only)
const getAllProprietaires = async (req, res, next) => {
  try {
    const pool = await getPool();
    const { immeubleId } = req.query;

    const syndicResult = await pool.request()
      .input('userId', sql.Int, req.user.id)
      .query('SELECT id FROM Syndics WHERE userId = @userId');
    const syndicId = syndicResult.recordset[0]?.id;

    let query = `
      SELECT p.*, u.email, u.isActive, i.nom AS immeubleNom
      FROM Proprietaires p
      INNER JOIN Users u ON p.userId = u.id
      LEFT JOIN  Immeubles i ON p.immeubleId = i.id
      WHERE i.syndicId = @syndicId
    `;

    const request = pool.request().input('syndicId', sql.Int, syndicId);
    if (immeubleId) {
      query += ' AND p.immeubleId = @immeubleId';
      request.input('immeubleId', sql.Int, immeubleId);
    }

    query += ' ORDER BY p.nom, p.prenom';
    const result = await request.query(query);
    res.json({ success: true, data: result.recordset });
  } catch (err) {
    next(err);
  }
};

// GET /api/proprietaires/:id
const getProprietaireById = async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query(`
        SELECT p.*, u.email, u.isActive, i.nom AS immeubleNom
        FROM Proprietaires p
        INNER JOIN Users u ON p.userId = u.id
        LEFT JOIN  Immeubles i ON p.immeubleId = i.id
        WHERE p.id = @id
      `);

    if (!result.recordset[0]) {
      return res.status(404).json({ success: false, message: 'Propriétaire not found.' });
    }
    res.json({ success: true, data: result.recordset[0] });
  } catch (err) {
    next(err);
  }
};

// PUT /api/proprietaires/:id
const updateProprietaire = async (req, res, next) => {
  try {
    const { nom, prenom, telephone, appartement, immeubleId } = req.body;
    const pool = await getPool();

    await pool.request()
      .input('id',          sql.Int,      req.params.id)
      .input('nom',         sql.NVarChar, nom)
      .input('prenom',      sql.NVarChar, prenom)
      .input('telephone',   sql.NVarChar, telephone || null)
      .input('appartement', sql.NVarChar, appartement || null)
      .input('immeubleId',  sql.Int,      immeubleId || null)
      .query(`
        UPDATE Proprietaires
        SET nom=@nom, prenom=@prenom, telephone=@telephone,
            appartement=@appartement, immeubleId=@immeubleId, updatedAt=GETDATE()
        WHERE id=@id
      `);

    res.json({ success: true, message: 'Propriétaire updated.' });
  } catch (err) {
    next(err);
  }
};

// GET /api/proprietaires/profile/me  (proprietaire self)
const getMyProfile = async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('userId', sql.Int, req.user.id)
      .query(`
        SELECT p.*, u.email, i.nom AS immeubleNom, i.adresse AS immeubleAdresse
        FROM Proprietaires p
        INNER JOIN Users u ON p.userId = u.id
        LEFT JOIN  Immeubles i ON p.immeubleId = i.id
        WHERE p.userId = @userId
      `);

    res.json({ success: true, data: result.recordset[0] });
  } catch (err) {
    next(err);
  }
};

module.exports = { getAllProprietaires, getProprietaireById, updateProprietaire, getMyProfile };
