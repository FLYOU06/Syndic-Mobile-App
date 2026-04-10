const { getPool, sql } = require('../config/database');

// GET /api/immeubles
const getAllImmeubles = async (req, res, next) => {
  try {
    const pool = await getPool();

    const syndicResult = await pool.request()
      .input('userId', sql.Int, req.user.id)
      .query('SELECT id FROM Syndics WHERE userId = @userId');
    const syndicId = syndicResult.recordset[0]?.id;

    const result = await pool.request()
      .input('syndicId', sql.Int, syndicId)
      .query(`
        SELECT i.*,
          (SELECT COUNT(*) FROM Proprietaires WHERE immeubleId = i.id) AS nombreProprietaires
        FROM Immeubles i
        WHERE i.syndicId = @syndicId
        ORDER BY i.nom
      `);

    res.json({ success: true, data: result.recordset });
  } catch (err) {
    next(err);
  }
};

// GET /api/immeubles/:id
const getImmeubleById = async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query(`
        SELECT i.*,
          (SELECT COUNT(*) FROM Proprietaires WHERE immeubleId = i.id) AS nombreProprietaires
        FROM Immeubles i
        WHERE i.id = @id
      `);

    if (!result.recordset[0]) {
      return res.status(404).json({ success: false, message: 'Immeuble not found.' });
    }
    res.json({ success: true, data: result.recordset[0] });
  } catch (err) {
    next(err);
  }
};

// POST /api/immeubles
const createImmeuble = async (req, res, next) => {
  try {
    const { nom, adresse, ville, nombreAppartements } = req.body;

    if (!nom || !adresse) {
      return res.status(400).json({ success: false, message: 'Nom and adresse are required.' });
    }

    const pool = await getPool();
    const syndicResult = await pool.request()
      .input('userId', sql.Int, req.user.id)
      .query('SELECT id FROM Syndics WHERE userId = @userId');
    const syndicId = syndicResult.recordset[0]?.id;

    const result = await pool.request()
      .input('syndicId',           sql.Int,      syndicId)
      .input('nom',                sql.NVarChar, nom)
      .input('adresse',            sql.NVarChar, adresse)
      .input('ville',              sql.NVarChar, ville || null)
      .input('nombreAppartements', sql.Int,      nombreAppartements || 0)
      .query(`
        INSERT INTO Immeubles (syndicId, nom, adresse, ville, nombreAppartements)
        OUTPUT INSERTED.*
        VALUES (@syndicId, @nom, @adresse, @ville, @nombreAppartements)
      `);

    res.status(201).json({ success: true, message: 'Immeuble created.', data: result.recordset[0] });
  } catch (err) {
    next(err);
  }
};

// PUT /api/immeubles/:id
const updateImmeuble = async (req, res, next) => {
  try {
    const { nom, adresse, ville, nombreAppartements } = req.body;
    const pool = await getPool();

    await pool.request()
      .input('id',                 sql.Int,      req.params.id)
      .input('nom',                sql.NVarChar, nom)
      .input('adresse',            sql.NVarChar, adresse)
      .input('ville',              sql.NVarChar, ville || null)
      .input('nombreAppartements', sql.Int,      nombreAppartements || 0)
      .query(`
        UPDATE Immeubles
        SET nom=@nom, adresse=@adresse, ville=@ville,
            nombreAppartements=@nombreAppartements, updatedAt=GETDATE()
        WHERE id=@id
      `);

    res.json({ success: true, message: 'Immeuble updated.' });
  } catch (err) {
    next(err);
  }
};

// DELETE /api/immeubles/:id
const deleteImmeuble = async (req, res, next) => {
  try {
    const pool = await getPool();
    await pool.request()
      .input('id', sql.Int, req.params.id)
      .query('DELETE FROM Immeubles WHERE id = @id');

    res.json({ success: true, message: 'Immeuble deleted.' });
  } catch (err) {
    next(err);
  }
};

module.exports = { getAllImmeubles, getImmeubleById, createImmeuble, updateImmeuble, deleteImmeuble };
