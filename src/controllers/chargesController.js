const { getPool, sql } = require('../config/database');
const notificationService = require('../services/notificationService');
const emailService        = require('../services/emailService');

// ── POST /api/charges  (syndic creates a charge) ─────────────────────
// Automatically creates a ChargeHabitants row for EVERY habitant in the immeuble.
const createCharge = async (req, res, next) => {
  try {
    const { immeubleId, nom, description, montantTotal, dateEcheance, type } = req.body;

    if (!immeubleId || !nom || !montantTotal || !dateEcheance)
      return res.status(400).json({ success: false, message: 'immeubleId, nom, montantTotal and dateEcheance are required.' });

    const pool = await getPool();

    // Verify immeuble belongs to this syndic
    const syndicRes = await pool.request()
      .input('userId', sql.Int, req.user.id)
      .query('SELECT id FROM Syndics WHERE userId = @userId');
    const syndicId = syndicRes.recordset[0]?.id;

    const immRes = await pool.request()
      .input('id',       sql.Int, immeubleId)
      .input('syndicId', sql.Int, syndicId)
      .query('SELECT id, nom FROM Immeubles WHERE id = @id AND syndicId = @syndicId');
    if (!immRes.recordset[0])
      return res.status(403).json({ success: false, message: 'Immeuble not found or not owned by you.' });

    // Insert the charge
    const chargeRes = await pool.request()
      .input('immeubleId',   sql.Int,           immeubleId)
      .input('nom',          sql.NVarChar,      nom)
      .input('description',  sql.NVarChar,      description || null)
      .input('montantTotal', sql.Decimal(10,2), montantTotal)
      .input('dateEcheance', sql.Date,          dateEcheance)
      .input('type',         sql.NVarChar,      type || null)
      .query(`
        INSERT INTO Charges (immeubleId, nom, description, montantTotal, dateEcheance, type)
        OUTPUT INSERTED.*
        VALUES (@immeubleId, @nom, @description, @montantTotal, @dateEcheance, @type)
      `);
    const charge = chargeRes.recordset[0];

    // Fetch all habitants in this immeuble
    const habitantsRes = await pool.request()
      .input('immeubleId', sql.Int, immeubleId)
      .query(`
        SELECT h.id AS habitantId, h.nom, h.prenom, u.id AS userId, u.email
        FROM   Habitants h
        INNER JOIN Users u ON h.userId = u.id
        WHERE  h.immeubleId = @immeubleId
      `);

    const habitants = habitantsRes.recordset;

    // Assign charge to every habitant (split equally)
    const montantParHabitant = habitants.length > 0
      ? parseFloat((montantTotal / habitants.length).toFixed(2))
      : parseFloat(montantTotal);

    for (const h of habitants) {
      await pool.request()
        .input('chargeId',    sql.Int,           charge.id)
        .input('habitantId',  sql.Int,           h.habitantId)
        .input('montantDu',   sql.Decimal(10,2), montantParHabitant)
        .query(`
          INSERT INTO ChargeHabitants (chargeId, habitantId, montantDu)
          VALUES (@chargeId, @habitantId, @montantDu)
        `);

      // In-app notification
      await notificationService.create(
        h.userId,
        'Nouvelle charge',
        `Une nouvelle charge "${nom}" de ${montantParHabitant} MAD vous a été assignée. Échéance : ${dateEcheance}.`,
        'charge'
      );
    }

    res.status(201).json({
      success: true,
      message: `Charge created and assigned to ${habitants.length} habitant(s).`,
      data: charge,
      assignedTo: habitants.length,
      montantParHabitant,
    });
  } catch (err) { next(err); }
};

// ── GET /api/charges  ────────────────────────────────────────────────
const getAllCharges = async (req, res, next) => {
  try {
    const pool = await getPool();
    const { immeubleId, page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;

    const conditions = [];
    const request    = pool.request();

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
      const habitantId = r.recordset[0]?.id;
      // Only return charges this habitant is assigned to
      conditions.push(`EXISTS (SELECT 1 FROM ChargeHabitants ch WHERE ch.chargeId = c.id AND ch.habitantId = ${habitantId})`);
    }

    if (immeubleId) { conditions.push('c.immeubleId = @immeubleId'); request.input('immeubleId', sql.Int, immeubleId); }

    const where = conditions.length ? 'WHERE ' + conditions.join(' AND ') : '';

    const result = await request.query(`
      SELECT c.*,
             i.nom AS immeubleNom,
             -- Aggregated payment summary
             (SELECT COUNT(*)                             FROM ChargeHabitants ch WHERE ch.chargeId = c.id)                                   AS totalHabitants,
             (SELECT COUNT(*)                             FROM ChargeHabitants ch WHERE ch.chargeId = c.id AND ch.statut = 'paid')            AS totalPaid,
             (SELECT COUNT(*)                             FROM ChargeHabitants ch WHERE ch.chargeId = c.id AND ch.statut = 'unpaid')          AS totalUnpaid,
             (SELECT COUNT(*)                             FROM ChargeHabitants ch WHERE ch.chargeId = c.id AND ch.statut = 'partially_paid')  AS totalPartiallyPaid,
             (SELECT ISNULL(SUM(ch.montantPaye),0)        FROM ChargeHabitants ch WHERE ch.chargeId = c.id)                                   AS totalMontantPercu,
             (SELECT ISNULL(SUM(ch.montantDu - ch.montantPaye),0) FROM ChargeHabitants ch WHERE ch.chargeId = c.id)                          AS totalMontantRestant
      FROM   Charges   c
      INNER JOIN Immeubles i ON c.immeubleId = i.id
      ${where}
      ORDER BY c.dateEcheance DESC
      OFFSET ${offset} ROWS FETCH NEXT ${limit} ROWS ONLY
    `);

    res.json({ success: true, data: result.recordset, page: Number(page), limit: Number(limit) });
  } catch (err) { next(err); }
};

// ── GET /api/charges/:id  (full detail + per-resident breakdown) ──────
const getChargeById = async (req, res, next) => {
  try {
    const pool = await getPool();

    // Charge header
    const chargeRes = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query(`
        SELECT c.*, i.nom AS immeubleNom
        FROM   Charges c
        INNER JOIN Immeubles i ON c.immeubleId = i.id
        WHERE c.id = @id
      `);
    if (!chargeRes.recordset[0])
      return res.status(404).json({ success: false, message: 'Charge not found.' });

    const charge = chargeRes.recordset[0];

    // Per-resident breakdown
    const rowsRes = await pool.request()
      .input('chargeId', sql.Int, charge.id)
      .query(`
        SELECT ch.*,
               h.nom AS habitantNom, h.prenom AS habitantPrenom,
               h.type AS habitantType, h.appartement,
               u.email
        FROM   ChargeHabitants ch
        INNER JOIN Habitants h ON ch.habitantId = h.id
        INNER JOIN Users     u ON h.userId      = u.id
        WHERE  ch.chargeId = @chargeId
        ORDER BY h.nom, h.prenom
      `);

    const rows = rowsRes.recordset;

    // Calculations
    const totalMontantDu      = rows.reduce((s, r) => s + parseFloat(r.montantDu),   0);
    const totalMontantPercu   = rows.reduce((s, r) => s + parseFloat(r.montantPaye), 0);
    const totalMontantRestant = totalMontantDu - totalMontantPercu;

    const summary = {
      totalHabitants:    rows.length,
      paid:              rows.filter(r => r.statut === 'paid').length,
      partiallyPaid:     rows.filter(r => r.statut === 'partially_paid').length,
      unpaid:            rows.filter(r => r.statut === 'unpaid').length,
      totalMontantDu:    +totalMontantDu.toFixed(2),
      totalMontantPercu: +totalMontantPercu.toFixed(2),
      totalMontantRestant: +totalMontantRestant.toFixed(2),
    };

    // Grouping by status
    const byStatus = {
      paid:          rows.filter(r => r.statut === 'paid'),
      partiallyPaid: rows.filter(r => r.statut === 'partially_paid'),
      unpaid:        rows.filter(r => r.statut === 'unpaid'),
    };

    res.json({ success: true, data: { charge, summary, byStatus, rows } });
  } catch (err) { next(err); }
};

// ── PUT /api/charges/:id  (syndic updates charge details) ────────────
const updateCharge = async (req, res, next) => {
  try {
    const { nom, description, montantTotal, dateEcheance, type } = req.body;
    const pool = await getPool();

    await pool.request()
      .input('id',          sql.Int,           req.params.id)
      .input('nom',         sql.NVarChar,      nom)
      .input('description', sql.NVarChar,      description || null)
      .input('montantTotal',sql.Decimal(10,2), montantTotal)
      .input('dateEcheance',sql.Date,          dateEcheance)
      .input('type',        sql.NVarChar,      type || null)
      .query(`
        UPDATE Charges
        SET nom=@nom, description=@description, montantTotal=@montantTotal,
            dateEcheance=@dateEcheance, type=@type, updatedAt=GETDATE()
        WHERE id = @id
      `);

    res.json({ success: true, message: 'Charge updated.' });
  } catch (err) { next(err); }
};

// ── DELETE /api/charges/:id ──────────────────────────────────────────
const deleteCharge = async (req, res, next) => {
  try {
    const pool = await getPool();
    await pool.request()
      .input('id', sql.Int, req.params.id)
      .query('DELETE FROM Charges WHERE id = @id');
    res.json({ success: true, message: 'Charge deleted.' });
  } catch (err) { next(err); }
};

// ── POST /api/charges/:id/paiement  (syndic records a payment) ───────
// Updates the ChargeHabitants row for this habitant.
const recordPaiement = async (req, res, next) => {
  try {
    const { habitantId, montantPaye, modePaiement, reference } = req.body;
    const chargeId = req.params.id;

    if (!habitantId || !montantPaye)
      return res.status(400).json({ success: false, message: 'habitantId and montantPaye are required.' });

    const pool = await getPool();

    // Fetch current row
    const rowRes = await pool.request()
      .input('chargeId',   sql.Int, chargeId)
      .input('habitantId', sql.Int, habitantId)
      .query(`
        SELECT ch.*, c.nom AS chargeNom, c.dateEcheance,
               h.nom AS habitantNom, h.prenom AS habitantPrenom, u.email
        FROM   ChargeHabitants ch
        INNER JOIN Charges  c ON ch.chargeId   = c.id
        INNER JOIN Habitants h ON ch.habitantId = h.id
        INNER JOIN Users     u ON h.userId      = u.id
        WHERE ch.chargeId = @chargeId AND ch.habitantId = @habitantId
      `);

    if (!rowRes.recordset[0])
      return res.status(404).json({ success: false, message: 'No charge assigned to this habitant.' });

    const row        = rowRes.recordset[0];
    const newPaye    = parseFloat(row.montantPaye) + parseFloat(montantPaye);
    const montantDu  = parseFloat(row.montantDu);

    if (newPaye > montantDu)
      return res.status(400).json({ success: false, message: `Overpayment: montantDu is ${montantDu} MAD, already paid ${row.montantPaye} MAD.` });

    // Determine new status
    let newStatut = 'partially_paid';
    if (newPaye >= montantDu) newStatut = 'paid';

    await pool.request()
      .input('chargeId',     sql.Int,           chargeId)
      .input('habitantId',   sql.Int,           habitantId)
      .input('montantPaye',  sql.Decimal(10,2), newPaye)
      .input('statut',       sql.NVarChar,      newStatut)
      .input('modePaiement', sql.NVarChar,      modePaiement || null)
      .input('reference',    sql.NVarChar,      reference    || null)
      .input('datePaiement', sql.DateTime,      new Date())
      .query(`
        UPDATE ChargeHabitants
        SET montantPaye=@montantPaye, statut=@statut, modePaiement=@modePaiement,
            reference=@reference, datePaiement=@datePaiement, updatedAt=GETDATE()
        WHERE chargeId=@chargeId AND habitantId=@habitantId
      `);

    // Get habitant userId for notification
    const hUserRes = await pool.request()
      .input('id', sql.Int, habitantId)
      .query('SELECT userId FROM Habitants WHERE id = @id');
    const habitantUserId = hUserRes.recordset[0]?.userId;

    if (newStatut === 'paid') {
      // Notify + email confirmation
      await notificationService.create(habitantUserId, 'Paiement confirmé ✅',
        `Votre paiement de ${montantPaye} MAD pour "${row.chargeNom}" a été enregistré. Votre solde est à jour.`, 'paiement');
      try {
        await emailService.sendPaymentConfirmation({ to: row.email, nom: row.habitantNom, prenom: row.habitantPrenom, chargeNom: row.chargeNom, montant: montantPaye });
      } catch (e) { console.error('[Email] confirmation:', e.message); }
    } else {
      await notificationService.create(habitantUserId, 'Paiement partiel enregistré',
        `Votre paiement partiel de ${montantPaye} MAD pour "${row.chargeNom}" a été enregistré. Reste dû : ${(montantDu - newPaye).toFixed(2)} MAD.`, 'paiement');
    }

    res.json({
      success: true,
      message: `Payment recorded. Status: ${newStatut}.`,
      data: { chargeId, habitantId, montantDu, montantPaye: newPaye, statut: newStatut },
    });
  } catch (err) { next(err); }
};

// ── POST /api/charges/:id/notify-unpaid  (notify all unpaid habitants) ─
const notifyUnpaid = async (req, res, next) => {
  try {
    const chargeId = req.params.id;
    const pool     = await getPool();

    const unpaidRes = await pool.request()
      .input('chargeId', sql.Int, chargeId)
      .query(`
        SELECT ch.montantDu, ch.montantPaye, c.nom AS chargeNom, c.dateEcheance,
               h.nom, h.prenom, h.userId, u.email
        FROM   ChargeHabitants ch
        INNER JOIN Charges  c ON ch.chargeId   = c.id
        INNER JOIN Habitants h ON ch.habitantId = h.id
        INNER JOIN Users     u ON h.userId      = u.id
        WHERE ch.chargeId = @chargeId AND ch.statut IN ('unpaid','partially_paid')
      `);

    let count = 0;
    for (const row of unpaidRes.recordset) {
      const restant = (parseFloat(row.montantDu) - parseFloat(row.montantPaye)).toFixed(2);

      await notificationService.create(row.userId, 'Rappel de paiement 🔔',
        `Vous avez un solde impayé de ${restant} MAD pour "${row.chargeNom}". Échéance : ${row.dateEcheance}.`, 'alerte');

      try {
        await emailService.sendPaymentReminder({
          to: row.email, nom: row.nom, prenom: row.prenom,
          chargeNom: row.chargeNom, montantDu: restant, dateEcheance: row.dateEcheance,
        });
      } catch (e) { console.error('[Email] reminder:', e.message); }

      count++;
    }

    res.json({ success: true, message: `${count} habitant(s) notified.`, notified: count });
  } catch (err) { next(err); }
};

// ── GET /api/charges/impayes/dashboard  (syndic dashboard) ───────────
const getImpayesDashboard = async (req, res, next) => {
  try {
    const pool = await getPool();

    const syndicRes = await pool.request()
      .input('userId', sql.Int, req.user.id)
      .query('SELECT id FROM Syndics WHERE userId = @userId');
    const syndicId = syndicRes.recordset[0]?.id;

    const summary = await pool.request()
      .input('syndicId', sql.Int, syndicId)
      .query(`
        SELECT
          i.id AS immeubleId, i.nom AS immeubleNom,
          COUNT(DISTINCT c.id)                                                              AS totalCharges,
          ISNULL(SUM(ch.montantDu),   0)                                                   AS totalDu,
          ISNULL(SUM(ch.montantPaye), 0)                                                   AS totalPercu,
          ISNULL(SUM(ch.montantDu - ch.montantPaye), 0)                                    AS totalRestant,
          SUM(CASE WHEN ch.statut = 'paid'           THEN 1 ELSE 0 END)                    AS nbPaid,
          SUM(CASE WHEN ch.statut = 'partially_paid' THEN 1 ELSE 0 END)                    AS nbPartiallyPaid,
          SUM(CASE WHEN ch.statut = 'unpaid'         THEN 1 ELSE 0 END)                    AS nbUnpaid
        FROM   Immeubles i
        INNER JOIN Charges          c  ON c.immeubleId  = i.id
        INNER JOIN ChargeHabitants  ch ON ch.chargeId   = c.id
        WHERE i.syndicId = @syndicId
        GROUP BY i.id, i.nom
        ORDER BY totalRestant DESC
      `);

    res.json({ success: true, data: summary.recordset });
  } catch (err) { next(err); }
};

module.exports = {
  createCharge, getAllCharges, getChargeById,
  updateCharge, deleteCharge,
  recordPaiement, notifyUnpaid, getImpayesDashboard,
};
