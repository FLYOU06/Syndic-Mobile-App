const { getPool, sql } = require('../config/database');
const notificationService = require('../services/notificationService');

const getAllAssemblees = async (req, res, next) => {
  try {
    const pool = await getPool();
    const conditions = [];

    if (req.user.role === 'syndic') {
      const r = await pool.request().input('userId', sql.Int, req.user.id)
        .query('SELECT id FROM Syndics WHERE userId = @userId');
      conditions.push(`ag.syndicId = ${r.recordset[0]?.id}`);
    }
    if (req.user.role === 'proprietaire' || req.user.role === 'locataire') {
      const r = await pool.request().input('userId', sql.Int, req.user.id)
        .query('SELECT immeubleId FROM Habitants WHERE userId = @userId');
      if (r.recordset[0]?.immeubleId) conditions.push(`ag.immeubleId = ${r.recordset[0].immeubleId}`);
    }

    const where = conditions.length ? 'WHERE ' + conditions.join(' AND ') : '';
    const result = await pool.request().query(`
      SELECT ag.*, i.nom AS immeubleNom, s.nom AS syndicNom, s.prenom AS syndicPrenom
      FROM AssembleesGenerales ag
      INNER JOIN Immeubles i ON ag.immeubleId = i.id
      INNER JOIN Syndics   s ON ag.syndicId   = s.id
      ${where} ORDER BY ag.dateAG DESC
    `);
    res.json({ success: true, data: result.recordset });
  } catch (err) { next(err); }
};

const getAssembleeById = async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool.request().input('id', sql.Int, req.params.id).query(`
      SELECT ag.*, i.nom AS immeubleNom, s.nom AS syndicNom, s.prenom AS syndicPrenom
      FROM AssembleesGenerales ag
      INNER JOIN Immeubles i ON ag.immeubleId = i.id
      INNER JOIN Syndics   s ON ag.syndicId   = s.id
      WHERE ag.id = @id
    `);
    if (!result.recordset[0]) return res.status(404).json({ success: false, message: 'Assemblée not found.' });
    res.json({ success: true, data: result.recordset[0] });
  } catch (err) { next(err); }
};

const createAssemblee = async (req, res, next) => {
  try {
    const { immeubleId, titre, description, dateAG, lieu, ordreJour } = req.body;
    if (!immeubleId || !titre || !dateAG)
      return res.status(400).json({ success: false, message: 'immeubleId, titre and dateAG are required.' });

    const pool = await getPool();
    const syndicRes = await pool.request().input('userId', sql.Int, req.user.id)
      .query('SELECT id FROM Syndics WHERE userId = @userId');
    const syndicId = syndicRes.recordset[0]?.id;

    const result = await pool.request()
      .input('immeubleId',  sql.Int,      immeubleId)
      .input('syndicId',    sql.Int,      syndicId)
      .input('titre',       sql.NVarChar, titre)
      .input('description', sql.NVarChar, description || null)
      .input('dateAG',      sql.DateTime, new Date(dateAG))
      .input('lieu',        sql.NVarChar, lieu || null)
      .input('ordreJour',   sql.NVarChar, ordreJour || null)
      .query(`INSERT INTO AssembleesGenerales (immeubleId,syndicId,titre,description,dateAG,lieu,ordreJour)
              OUTPUT INSERTED.* VALUES (@immeubleId,@syndicId,@titre,@description,@dateAG,@lieu,@ordreJour)`);

    // Notify all habitants
    const habitants = await pool.request().input('immeubleId', sql.Int, immeubleId)
      .query('SELECT userId FROM Habitants WHERE immeubleId = @immeubleId');
    const msg = `Une assemblée générale "${titre}" est planifiée le ${new Date(dateAG).toLocaleDateString('fr-FR')}.`;
    for (const h of habitants.recordset) {
      await notificationService.create(h.userId, 'Nouvelle Assemblée Générale 📅', msg, 'assemblee');
    }

    res.status(201).json({ success: true, message: 'Assemblée created.', data: result.recordset[0] });
  } catch (err) { next(err); }
};

const updateAssemblee = async (req, res, next) => {
  try {
    const { titre, description, dateAG, lieu, statut, ordreJour, procesVerbal } = req.body;
    const pool = await getPool();
    await pool.request()
      .input('id',          sql.Int,      req.params.id)
      .input('titre',       sql.NVarChar, titre)
      .input('description', sql.NVarChar, description  || null)
      .input('dateAG',      sql.DateTime, new Date(dateAG))
      .input('lieu',        sql.NVarChar, lieu         || null)
      .input('statut',      sql.NVarChar, statut)
      .input('ordreJour',   sql.NVarChar, ordreJour    || null)
      .input('procesVerbal',sql.NVarChar, procesVerbal || null)
      .query(`UPDATE AssembleesGenerales SET titre=@titre, description=@description, dateAG=@dateAG,
              lieu=@lieu, statut=@statut, ordreJour=@ordreJour, procesVerbal=@procesVerbal, updatedAt=GETDATE()
              WHERE id=@id`);
    res.json({ success: true, message: 'Assemblée updated.' });
  } catch (err) { next(err); }
};

const deleteAssemblee = async (req, res, next) => {
  try {
    const pool = await getPool();
    await pool.request().input('id', sql.Int, req.params.id).query('DELETE FROM AssembleesGenerales WHERE id=@id');
    res.json({ success: true, message: 'Assemblée deleted.' });
  } catch (err) { next(err); }
};

module.exports = { getAllAssemblees, getAssembleeById, createAssemblee, updateAssemblee, deleteAssemblee };
