const { getPool, sql } = require('../config/database');
const notificationService = require('../services/notificationService');

// GET /api/paiements
const getAllPaiements = async (req, res, next) => {
  try {
    const pool  = await getPool();
    const { habitantId, chargeId, page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;
    const conditions = [];

    // Habitant sees only their own payments
    if (req.user.role === 'proprietaire' || req.user.role === 'locataire') {
      const r = await pool.request()
        .input('userId', sql.Int, req.user.id)
        .query('SELECT id FROM Habitants WHERE userId = @userId');
      conditions.push(`pay.habitantId = ${r.recordset[0]?.id}`);
    } else if (habitantId) {
      conditions.push(`pay.habitantId = ${habitantId}`);
    }

    if (chargeId) conditions.push(`pay.chargeId = ${chargeId}`);
    const where = conditions.length ? 'WHERE ' + conditions.join(' AND ') : '';

    const result = await pool.request().query(`
      SELECT pay.*,
             c.nom   AS chargeNom, c.montant AS chargeMontant,
             h.nom   AS habitantNom, h.prenom AS habitantPrenom, h.type AS habitantType
      FROM Paiements pay
      INNER JOIN Charges  c ON pay.chargeId   = c.id
      LEFT JOIN  Habitants h ON pay.habitantId = h.id
      ${where}
      ORDER BY pay.datePaiement DESC
      OFFSET ${offset} ROWS FETCH NEXT ${limit} ROWS ONLY
    `);

    res.json({ success: true, data: result.recordset, page: Number(page), limit: Number(limit) });
  } catch (err) { next(err); }
};

// POST /api/paiements  (syndic records a payment)
const createPaiement = async (req, res, next) => {
  try {
    const { chargeId, habitantId, montant, modePaiement, reference } = req.body;

    if (!chargeId || !habitantId || !montant)
      return res.status(400).json({ success: false, message: 'chargeId, habitantId and montant are required.' });

    const pool = await getPool();

    const result = await pool.request()
      .input('chargeId',    sql.Int,           chargeId)
      .input('habitantId',  sql.Int,           habitantId)
      .input('montant',     sql.Decimal(10,2), montant)
      .input('modePaiement',sql.NVarChar,      modePaiement || null)
      .input('reference',   sql.NVarChar,      reference    || null)
      .query(`
        INSERT INTO Paiements (chargeId, habitantId, montant, modePaiement, reference)
        OUTPUT INSERTED.*
        VALUES (@chargeId, @habitantId, @montant, @modePaiement, @reference)
      `);

    // Mark charge as paid
    await pool.request()
      .input('id', sql.Int, chargeId)
      .query(`UPDATE Charges SET statut='paye', updatedAt=GETDATE() WHERE id=@id`);

    // Notify the habitant who paid
    const habitantRes = await pool.request()
      .input('id', sql.Int, habitantId)
      .query('SELECT userId FROM Habitants WHERE id = @id');

    if (habitantRes.recordset[0]) {
      await notificationService.create(
        habitantRes.recordset[0].userId,
        'Paiement confirmé',
        `Votre paiement de ${montant} MAD a été enregistré. Référence : ${reference || 'N/A'}.`,
        'paiement'
      );
    }

    res.status(201).json({ success: true, message: 'Payment recorded.', data: result.recordset[0] });
  } catch (err) { next(err); }
};

// GET /api/paiements/suivi/:habitantId
const getSuiviPaiements = async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('habitantId', sql.Int, req.params.habitantId)
      .query(`
        SELECT c.id AS chargeId, c.nom AS chargeNom, c.description,
               c.montant, c.dateEcheance, c.statut, c.type,
               pay.id AS paiementId, pay.datePaiement, pay.modePaiement, pay.reference
        FROM Charges c
        LEFT JOIN Paiements pay ON c.id = pay.chargeId AND pay.habitantId = @habitantId
        WHERE c.habitantId = @habitantId
        ORDER BY c.dateEcheance DESC
      `);

    res.json({ success: true, data: result.recordset });
  } catch (err) { next(err); }
};

module.exports = { getAllPaiements, createPaiement, getSuiviPaiements };
