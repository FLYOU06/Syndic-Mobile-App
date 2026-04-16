/**
 * assembleesController.js
 *
 * Matched field-by-field to assembly_dashboard_screen.dart:
 *
 * Flutter reads (GET list):
 *   data['assemblees'] ?? data['data'] ?? []
 *   ag['id'], ag['date'], ag['heure'], ag['lieu'], ag['type'],
 *   ag['ordreDuJour'] (List of {titre, description})
 *
 * Flutter sends (POST / PUT body via _buildAssembleeBody()):
 *   titre, type, date (ISO), heure, lieu,
 *   ordreDuJour: [{titre, description}],
 *   statut, presents, absents, procurations, pvGenere
 *
 * Flutter reads after create/update:
 *   result['data'] ?? result['assemblee'] ?? result
 *   ag['id']
 *
 * Flutter sendNotification body:
 *   { titre, message, type:"convocation_ag"|"pv_ag", assemblee_id }
 *   → handled by notificationsController + immeubleId stored on the assemblee
 */

const { getPool, sql } = require('../config/database');
const notificationService = require('../services/notificationService');

// ─── helper: get syndicId from userId ───────────────────────────────
const getSyndicId = async (pool, userId) => {
  const r = await pool.request()
    .input('userId', sql.Int, userId)
    .query('SELECT id FROM Syndics WHERE userId = @userId');
  return r.recordset[0]?.id ?? null;
};

// ─── helper: get immeubleId for this syndic ──────────────────────────
// Uses first immeuble if not specified — Flutter screen doesn't send immeubleId
const getDefaultImmeubleId = async (pool, syndicId) => {
  const r = await pool.request()
    .input('syndicId', sql.Int, syndicId)
    .query('SELECT TOP 1 id FROM Immeubles WHERE syndicId = @syndicId ORDER BY id');
  return r.recordset[0]?.id ?? null;
};

// ─── helper: parse ordreDuJour (JSON string ↔ array) ────────────────
const parseOrdreJour = (raw) => {
  if (!raw) return [];
  if (Array.isArray(raw)) return raw;
  try { return JSON.parse(raw); } catch { return []; }
};

// ─── helper: format one assemblee row for Flutter ───────────────────
// Flutter prefill uses: id, date, heure, lieu, type, ordreDuJour[]
const formatForFlutter = (row) => ({
  id:           row.id,
  titre:        row.titre,
  type:         row.type,          // 'ordinaire' | 'extraordinaire'
  date:         row.dateAG
                  ? (row.dateAG instanceof Date
                      ? row.dateAG.toISOString().split('T')[0]
                      : String(row.dateAG).split('T')[0])
                  : null,
  heure:        row.heure,
  lieu:         row.lieu,
  statut:       row.statut,
  description:  row.description,
  ordreDuJour:  parseOrdreJour(row.ordreJour),  // always an array
  procesVerbal: row.procesVerbal,
  presents:     row.presents     ?? 0,
  absents:      row.absents      ?? 0,
  procurations: row.procurations ?? 0,
  pvGenere:     row.pvGenere     === true || row.pvGenere === 1,
  convocation:  row.convocation  ?? null,
  immeubleId:   row.immeubleId,
  immeubleNom:  row.immeubleNom,
  syndicNom:    row.syndicNom,
  syndicPrenom: row.syndicPrenom,
  createdAt:    row.createdAt,
  updatedAt:    row.updatedAt,
});

// ══════════════════════════════════════════════════════════════════════
//  GET /api/assemblees
//  Flutter: final data = await ApiService.getAssemblees();
//           final List list = data is List ? data : (data['assemblees'] ?? data['data'] ?? []);
// ══════════════════════════════════════════════════════════════════════
const getAllAssemblees = async (req, res, next) => {
  try {
    const pool = await getPool();
    const conditions = [];

    if (req.user.role === 'syndic') {
      const syndicId = await getSyndicId(pool, req.user.id);
      if (syndicId) conditions.push(`ag.syndicId = ${syndicId}`);
    }

    if (req.user.role === 'proprietaire' || req.user.role === 'locataire') {
      const r = await pool.request()
        .input('userId', sql.Int, req.user.id)
        .query('SELECT immeubleId FROM Habitants WHERE userId = @userId');
      const immId = r.recordset[0]?.immeubleId;
      if (immId) conditions.push(`ag.immeubleId = ${immId}`);
      else return res.json({ success: true, assemblees: [] });
    }

    const where = conditions.length ? 'WHERE ' + conditions.join(' AND ') : '';

    const result = await pool.request().query(`
      SELECT ag.*,
             i.nom    AS immeubleNom,
             s.nom    AS syndicNom,
             s.prenom AS syndicPrenom
      FROM AssembleesGenerales ag
      INNER JOIN Immeubles i ON ag.immeubleId = i.id
      INNER JOIN Syndics   s ON ag.syndicId   = s.id
      ${where}
      ORDER BY ag.dateAG DESC
    `);

    // ← Flutter reads data['assemblees'] first
    res.json({
      success:    true,
      assemblees: result.recordset.map(formatForFlutter),
    });
  } catch (err) { next(err); }
};

// ══════════════════════════════════════════════════════════════════════
//  GET /api/assemblees/:id
// ══════════════════════════════════════════════════════════════════════
const getAssembleeById = async (req, res, next) => {
  try {
    const pool   = await getPool();
    const result = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query(`
        SELECT ag.*,
               i.nom    AS immeubleNom,
               s.nom    AS syndicNom,
               s.prenom AS syndicPrenom
        FROM AssembleesGenerales ag
        INNER JOIN Immeubles i ON ag.immeubleId = i.id
        INNER JOIN Syndics   s ON ag.syndicId   = s.id
        WHERE ag.id = @id
      `);

    if (!result.recordset[0])
      return res.status(404).json({ success: false, message: 'Assemblée not found.' });

    // ← Flutter reads result['data'] after create/update
    res.json({ success: true, data: formatForFlutter(result.recordset[0]) });
  } catch (err) { next(err); }
};

// ══════════════════════════════════════════════════════════════════════
//  POST /api/assemblees
//  Flutter body (_buildAssembleeBody()):
//    { titre, type, date (ISO), heure, lieu, ordreDuJour:[{titre,description}], statut }
//  Flutter reads: result['data'] ?? result['assemblee'] ?? result  → ag['id']
// ══════════════════════════════════════════════════════════════════════
const createAssemblee = async (req, res, next) => {
  try {
    const {
      titre, type, date, heure, lieu,
      ordreDuJour, statut, description,
      convocation,
      immeubleId: bodyImmeubleId,
    } = req.body;

    if (!titre || !date)
      return res.status(400).json({ success: false, message: 'titre and date are required.' });

    const pool     = await getPool();
    const syndicId = await getSyndicId(pool, req.user.id);
    if (!syndicId)
      return res.status(403).json({ success: false, message: 'Syndic profile not found.' });

    // Use provided immeubleId or fallback to first immeuble of this syndic
    const immeubleId = bodyImmeubleId ?? await getDefaultImmeubleId(pool, syndicId);
    if (!immeubleId)
      return res.status(400).json({ success: false, message: 'No immeuble found for this syndic. Create one first.' });

    // Serialize ordreDuJour array → JSON string for storage
    const ordreJourJson = ordreDuJour
      ? JSON.stringify(Array.isArray(ordreDuJour) ? ordreDuJour : [])
      : '[]';

    const agType = (type || 'ordinaire').toLowerCase();

    const result = await pool.request()
      .input('immeubleId',  sql.Int,      immeubleId)
      .input('syndicId',    sql.Int,      syndicId)
      .input('titre',       sql.NVarChar, titre)
      .input('type',        sql.NVarChar, agType)
      .input('description', sql.NVarChar, description || null)
      .input('dateAG',      sql.Date,     date)
      .input('heure',       sql.NVarChar, heure || null)
      .input('lieu',        sql.NVarChar, lieu  || null)
      .input('statut',      sql.NVarChar, statut || 'planifiee')
      .input('ordreJour',   sql.NVarChar, ordreJourJson)
      .input('convocation', sql.NVarChar, convocation || null)
      .query(`
        INSERT INTO AssembleesGenerales
          (immeubleId, syndicId, titre, type, description, dateAG, heure, lieu, statut, ordreJour, convocation)
        OUTPUT INSERTED.*
        VALUES
          (@immeubleId, @syndicId, @titre, @type, @description, @dateAG, @heure, @lieu, @statut, @ordreJour, @convocation)
      `);

    const created = formatForFlutter(result.recordset[0]);

    // Notify all habitants in this building
    const habitants = await pool.request()
      .input('immeubleId', sql.Int, immeubleId)
      .query('SELECT userId FROM Habitants WHERE immeubleId = @immeubleId');

    const dateStr = date;
    const msg = `Une assemblée générale ${agType} "${titre}" est planifiée le ${dateStr}${heure ? ' à ' + heure : ''}${lieu ? ', ' + lieu : ''}.`;

    for (const h of habitants.recordset) {
      await notificationService.create(h.userId, 'Nouvelle Assemblée Générale 📅', msg, 'assemblee');
    }

    // ← Flutter reads result['data'] → ag['id']
    res.status(201).json({
      success:  true,
      message:  `Assemblée créée. ${habitants.recordset.length} habitant(s) notifié(s).`,
      data:     created,         // primary key Flutter uses
      assemblee: created,        // fallback Flutter reads
    });
  } catch (err) { next(err); }
};

// ══════════════════════════════════════════════════════════════════════
//  PUT /api/assemblees/:id
//  Flutter sends 3 different payloads:
//    1. _buildAssembleeBody()                          → save AG details
//    2. _buildAssembleeBody() + presents/absents/…     → save presences (statut=en_cours)
//    3. _buildAssembleeBody() + presents/… + pvGenere  → finalize (statut=terminee)
// ══════════════════════════════════════════════════════════════════════
const updateAssemblee = async (req, res, next) => {
  try {
    const {
      titre, type, date, heure, lieu,
      ordreDuJour, statut, description,
      presents, absents, procurations, pvGenere, convocation,
    } = req.body;

    const pool = await getPool();

    // Fetch current row to keep existing values if Flutter omits them
    const existing = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query('SELECT * FROM AssembleesGenerales WHERE id = @id');

    if (!existing.recordset[0])
      return res.status(404).json({ success: false, message: 'Assemblée not found.' });

    const cur = existing.recordset[0];

    const ordreJourJson = ordreDuJour != null
      ? JSON.stringify(Array.isArray(ordreDuJour) ? ordreDuJour : [])
      : cur.ordreJour;

    const newStatut = statut || cur.statut;
    // Validate statut against allowed values
    const validStatuts = ['planifiee', 'en_cours', 'terminee', 'annulee'];
    const finalStatut  = validStatuts.includes(newStatut) ? newStatut : cur.statut;

    await pool.request()
      .input('id',           sql.Int,      req.params.id)
      .input('titre',        sql.NVarChar, titre       || cur.titre)
      .input('type',         sql.NVarChar, (type || cur.type || 'ordinaire').toLowerCase())
      .input('description',  sql.NVarChar, description ?? cur.description)
      .input('dateAG',       sql.Date,     date        || cur.dateAG)
      .input('heure',        sql.NVarChar, heure       ?? cur.heure)
      .input('lieu',         sql.NVarChar, lieu        ?? cur.lieu)
      .input('statut',       sql.NVarChar, finalStatut)
      .input('ordreJour',    sql.NVarChar, ordreJourJson)
      .input('presents',     sql.Int,      presents     ?? cur.presents     ?? 0)
      .input('absents',      sql.Int,      absents      ?? cur.absents      ?? 0)
      .input('procurations', sql.Int,      procurations ?? cur.procurations ?? 0)
      .input('pvGenere',     sql.Bit,      pvGenere     != null ? (pvGenere ? 1 : 0) : (cur.pvGenere ?? 0))
      .input('convocation', sql.NVarChar, convocation !== undefined ? convocation : (cur.convocation ?? null))
      .query(`
        UPDATE AssembleesGenerales SET
          titre        = @titre,
          type         = @type,
          description  = @description,
          dateAG       = @dateAG,
          heure        = @heure,
          lieu         = @lieu,
          statut       = @statut,
          ordreJour    = @ordreJour,
          presents     = @presents,
          absents      = @absents,
          procurations = @procurations,
          pvGenere     = @pvGenere,
          convocation  = @convocation,
          updatedAt    = GETDATE()
        WHERE id = @id
      `);

    // Return updated row so Flutter can get ag['id']
    const updated = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query(`
        SELECT ag.*,
               i.nom    AS immeubleNom,
               s.nom    AS syndicNom,
               s.prenom AS syndicPrenom
        FROM AssembleesGenerales ag
        INNER JOIN Immeubles i ON ag.immeubleId = i.id
        INNER JOIN Syndics   s ON ag.syndicId   = s.id
        WHERE ag.id = @id
      `);

    const formatted = formatForFlutter(updated.recordset[0]);

    // ← Flutter reads result['data'] ?? result['assemblee'] ?? result
    res.json({
      success:   true,
      message:   'Assemblée mise à jour.',
      data:      formatted,
      assemblee: formatted,
    });
  } catch (err) { next(err); }
};

// ══════════════════════════════════════════════════════════════════════
//  DELETE /api/assemblees/:id
// ══════════════════════════════════════════════════════════════════════
const deleteAssemblee = async (req, res, next) => {
  try {
    const pool = await getPool();
    await pool.request()
      .input('id', sql.Int, req.params.id)
      .query('DELETE FROM AssembleesGenerales WHERE id = @id');
    res.json({ success: true, message: 'Assemblée supprimée.' });
  } catch (err) { next(err); }
};

module.exports = {
  getAllAssemblees,
  getAssembleeById,
  createAssemblee,
  updateAssemblee,
  deleteAssemblee,
};
