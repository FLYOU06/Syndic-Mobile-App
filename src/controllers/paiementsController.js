const { getPool, sql } = require('../config/database');
const notificationService = require('../services/notificationService');

// GET /api/paiements
const getAllPaiements = async (req, res, next) => {
  try {
    const pool = await getPool();
    const { proprietaireId, chargeId, page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;

    let baseConditions = [];
    const request = pool.request();

    // Proprietaire only sees their own
    if (req.user.role === 'proprietaire') {
      const propResult = await pool.request()
        .input('userId', sql.Int, req.user.id)
        .query('SELECT id FROM Proprietaires WHERE userId = @userId');
      const propId = propResult.recordset[0]?.id;
      baseConditions.push(`p2.id = ${propId}`);
    } else if (proprietaireId) {
      baseConditions.push(`p2.id = ${proprietaireId}`);
    }

    if (chargeId) baseConditions.push(`pay.chargeId = ${chargeId}`);

    const whereClause = baseConditions.length ? 'WHERE ' + baseConditions.join(' AND ') : '';

    const result = await request.query(`
      SELECT pay.*, 
             c.description AS chargeDescription, c.montant AS chargeMontant,
             p2.nom AS proprietaireNom, p2.prenom AS proprietairePrenom
      FROM Paiements pay
      INNER JOIN Charges c ON pay.chargeId = c.id
      INNER JOIN Proprietaires p2 ON pay.proprietaireId = p2.id
      ${whereClause}
      ORDER BY pay.datePaiement DESC
      OFFSET ${offset} ROWS FETCH NEXT ${limit} ROWS ONLY
    `);

    res.json({ success: true, data: result.recordset, page: Number(page), limit: Number(limit) });
  } catch (err) {
    next(err);
  }
};

// POST /api/paiements  (syndic records a payment)
const createPaiement = async (req, res, next) => {
  try {
    const { chargeId, proprietaireId, montant, modePaiement, reference } = req.body;

    if (!chargeId || !proprietaireId || !montant) {
      return res.status(400).json({ success: false, message: 'Missing required fields.' });
    }

    const pool = await getPool();

    // Record the payment
    const result = await pool.request()
      .input('chargeId',       sql.Int,           chargeId)
      .input('proprietaireId', sql.Int,           proprietaireId)
      .input('montant',        sql.Decimal(10,2), montant)
      .input('modePaiement',   sql.NVarChar,      modePaiement || null)
      .input('reference',      sql.NVarChar,      reference || null)
      .query(`
        INSERT INTO Paiements (chargeId, proprietaireId, montant, modePaiement, reference)
        OUTPUT INSERTED.*
        VALUES (@chargeId, @proprietaireId, @montant, @modePaiement, @reference)
      `);

    // Mark charge as paid
    await pool.request()
      .input('id', sql.Int, chargeId)
      .query(`UPDATE Charges SET statut='paye', updatedAt=GETDATE() WHERE id=@id`);

    // Notify proprietaire
    const propUser = await pool.request()
      .input('propId', sql.Int, proprietaireId)
      .query('SELECT userId FROM Proprietaires WHERE id = @propId');

    if (propUser.recordset[0]) {
      await notificationService.create(
        propUser.recordset[0].userId,
        'Paiement confirmé',
        `Votre paiement de ${montant} MAD a été enregistré avec succès.`,
        'paiement'
      );
    }

    res.status(201).json({ success: true, message: 'Payment recorded.', data: result.recordset[0] });
  } catch (err) {
    next(err);
  }
};

// GET /api/paiements/suivi/:proprietaireId  — payment tracking for a proprietaire
const getSuiviPaiements = async (req, res, next) => {
  try {
    const pool = await getPool();
    const { proprietaireId } = req.params;

    const result = await pool.request()
      .input('propId', sql.Int, proprietaireId)
      .query(`
        SELECT c.id AS chargeId, c.description, c.montant, c.dateEcheance, c.statut, c.type,
               pay.id AS paiementId, pay.datePaiement, pay.modePaiement, pay.reference
        FROM Charges c
        LEFT JOIN Paiements pay ON c.id = pay.chargeId AND pay.proprietaireId = @propId
        WHERE c.proprietaireId = @propId
        ORDER BY c.dateEcheance DESC
      `);

    res.json({ success: true, data: result.recordset });
  } catch (err) {
    next(err);
  }
};

module.exports = { getAllPaiements, createPaiement, getSuiviPaiements };
