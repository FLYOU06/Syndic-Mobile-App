const { getPool, sql } = require('../config/database');
const notificationService = require('../services/notificationService');

// GET /api/assemblees
const getAllAssemblees = async (req, res, next) => {
  try {
    const pool = await getPool();
    const { statut, immeubleId } = req.query;

    let query = `
      SELECT ag.*, i.nom AS immeubleNom,
             s.nom AS syndicNom, s.prenom AS syndicPrenom
      FROM AssembleesGenerales ag
      INNER JOIN Immeubles i ON ag.immeubleId = i.id
      INNER JOIN Syndics s ON ag.syndicId = s.id
    `;

    const conditions = [];

    if (req.user.role === 'syndic') {
      const syndicResult = await pool.request()
        .input('userId', sql.Int, req.user.id)
        .query('SELECT id FROM Syndics WHERE userId = @userId');
      const syndicId = syndicResult.recordset[0]?.id;
      conditions.push(`ag.syndicId = ${syndicId}`);
    }

    if (req.user.role === 'proprietaire') {
      const propResult = await pool.request()
        .input('userId', sql.Int, req.user.id)
        .query('SELECT immeubleId FROM Proprietaires WHERE userId = @userId');
      const immId = propResult.recordset[0]?.immeubleId;
      if (immId) conditions.push(`ag.immeubleId = ${immId}`);
    }

    if (statut) conditions.push(`ag.statut = '${statut}'`);
    if (immeubleId) conditions.push(`ag.immeubleId = ${immeubleId}`);
    if (conditions.length) query += ' WHERE ' + conditions.join(' AND ');

    query += ' ORDER BY ag.dateAG DESC';

    const result = await pool.request().query(query);
    res.json({ success: true, data: result.recordset });
  } catch (err) {
    next(err);
  }
};

// GET /api/assemblees/:id
const getAssembleeById = async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query(`
        SELECT ag.*, i.nom AS immeubleNom,
               s.nom AS syndicNom, s.prenom AS syndicPrenom
        FROM AssembleesGenerales ag
        INNER JOIN Immeubles i ON ag.immeubleId = i.id
        INNER JOIN Syndics s ON ag.syndicId = s.id
        WHERE ag.id = @id
      `);

    if (!result.recordset[0]) {
      return res.status(404).json({ success: false, message: 'Assemblée not found.' });
    }
    res.json({ success: true, data: result.recordset[0] });
  } catch (err) {
    next(err);
  }
};

// POST /api/assemblees  (syndic only)
const createAssemblee = async (req, res, next) => {
  try {
    const { immeubleId, titre, description, dateAG, lieu, ordreJour } = req.body;

    if (!immeubleId || !titre || !dateAG) {
      return res.status(400).json({ success: false, message: 'Missing required fields.' });
    }

    const pool = await getPool();

    const syndicResult = await pool.request()
      .input('userId', sql.Int, req.user.id)
      .query('SELECT id FROM Syndics WHERE userId = @userId');
    const syndicId = syndicResult.recordset[0]?.id;

    const result = await pool.request()
      .input('immeubleId',  sql.Int,      immeubleId)
      .input('syndicId',    sql.Int,      syndicId)
      .input('titre',       sql.NVarChar, titre)
      .input('description', sql.NVarChar, description || null)
      .input('dateAG',      sql.DateTime, new Date(dateAG))
      .input('lieu',        sql.NVarChar, lieu || null)
      .input('ordreJour',   sql.NVarChar, ordreJour || null)
      .query(`
        INSERT INTO AssembleesGenerales (immeubleId, syndicId, titre, description, dateAG, lieu, ordreJour)
        OUTPUT INSERTED.*
        VALUES (@immeubleId, @syndicId, @titre, @description, @dateAG, @lieu, @ordreJour)
      `);

    // Notify all proprietaires of this building
    const proprietaires = await pool.request()
      .input('immeubleId', sql.Int, immeubleId)
      .query('SELECT userId FROM Proprietaires WHERE immeubleId = @immeubleId');

    for (const prop of proprietaires.recordset) {
      await notificationService.create(
        prop.userId,
        'Nouvelle Assemblée Générale',
        `Une assemblée générale "${titre}" est planifiée le ${new Date(dateAG).toLocaleDateString('fr-FR')}.`,
        'assemblee'
      );
    }

    res.status(201).json({ success: true, message: 'Assemblée created.', data: result.recordset[0] });
  } catch (err) {
    next(err);
  }
};

// PUT /api/assemblees/:id  (syndic only)
const updateAssemblee = async (req, res, next) => {
  try {
    const { titre, description, dateAG, lieu, statut, ordreJour, procèsVerbal } = req.body;
    const pool = await getPool();

    await pool.request()
      .input('id',           sql.Int,      req.params.id)
      .input('titre',        sql.NVarChar, titre)
      .input('description',  sql.NVarChar, description || null)
      .input('dateAG',       sql.DateTime, new Date(dateAG))
      .input('lieu',         sql.NVarChar, lieu || null)
      .input('statut',       sql.NVarChar, statut)
      .input('ordreJour',    sql.NVarChar, ordreJour || null)
      .input('procèsVerbal', sql.NVarChar, procèsVerbal || null)
      .query(`
        UPDATE AssembleesGenerales
        SET titre=@titre, description=@description, dateAG=@dateAG, lieu=@lieu,
            statut=@statut, ordreJour=@ordreJour, procèsVerbal=@procèsVerbal, updatedAt=GETDATE()
        WHERE id=@id
      `);

    res.json({ success: true, message: 'Assemblée updated.' });
  } catch (err) {
    next(err);
  }
};

// DELETE /api/assemblees/:id
const deleteAssemblee = async (req, res, next) => {
  try {
    const pool = await getPool();
    await pool.request()
      .input('id', sql.Int, req.params.id)
      .query('DELETE FROM AssembleesGenerales WHERE id = @id');

    res.json({ success: true, message: 'Assemblée deleted.' });
  } catch (err) {
    next(err);
  }
};

module.exports = { getAllAssemblees, getAssembleeById, createAssemblee, updateAssemblee, deleteAssemblee };
