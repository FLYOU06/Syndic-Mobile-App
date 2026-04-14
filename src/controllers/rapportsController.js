const { getPool, sql } = require('../config/database');

const getRapportFinancier = async (req, res, next) => {
  try {
    const { immeubleId, dateDebut, dateFin } = req.query;
    const pool = await getPool();

    const syndicRes = await pool.request().input('userId', sql.Int, req.user.id)
      .query('SELECT id FROM Syndics WHERE userId = @userId');
    const syndicId = syndicRes.recordset[0]?.id;

    let filter = `i.syndicId = ${syndicId}`;
    if (immeubleId) filter += ` AND i.id = ${immeubleId}`;
    if (dateDebut)  filter += ` AND c.createdAt >= '${dateDebut}'`;
    if (dateFin)    filter += ` AND c.createdAt <= '${dateFin}'`;

    const totaux = await pool.request().query(`
      SELECT
        COUNT(DISTINCT c.id)                                               AS totalCharges,
        ISNULL(SUM(ch.montantDu),0)                                        AS totalDu,
        ISNULL(SUM(ch.montantPaye),0)                                      AS totalPercu,
        ISNULL(SUM(ch.montantDu - ch.montantPaye),0)                       AS totalRestant,
        SUM(CASE WHEN ch.statut='paid'           THEN 1 ELSE 0 END)        AS nbPaid,
        SUM(CASE WHEN ch.statut='partially_paid' THEN 1 ELSE 0 END)        AS nbPartiallyPaid,
        SUM(CASE WHEN ch.statut='unpaid'         THEN 1 ELSE 0 END)        AS nbUnpaid
      FROM Charges c
      INNER JOIN Immeubles       i  ON c.immeubleId = i.id
      INNER JOIN ChargeHabitants ch ON ch.chargeId  = c.id
      WHERE ${filter}
    `);

    const parImmeuble = await pool.request().query(`
      SELECT i.id, i.nom,
        COUNT(DISTINCT c.id)                                 AS totalCharges,
        ISNULL(SUM(ch.montantDu),0)                          AS totalDu,
        ISNULL(SUM(ch.montantPaye),0)                        AS totalPercu,
        ISNULL(SUM(ch.montantDu - ch.montantPaye),0)         AS totalRestant
      FROM Charges c
      INNER JOIN Immeubles       i  ON c.immeubleId = i.id
      INNER JOIN ChargeHabitants ch ON ch.chargeId  = c.id
      WHERE ${filter}
      GROUP BY i.id, i.nom
    `);

    const tendance = await pool.request().query(`
      SELECT FORMAT(c.createdAt,'yyyy-MM') AS mois,
             ISNULL(SUM(ch.montantDu),0)    AS totalDu,
             ISNULL(SUM(ch.montantPaye),0)  AS totalPercu
      FROM Charges c
      INNER JOIN Immeubles       i  ON c.immeubleId = i.id
      INNER JOIN ChargeHabitants ch ON ch.chargeId  = c.id
      WHERE i.syndicId = ${syndicId} AND c.createdAt >= DATEADD(MONTH,-12,GETDATE())
      GROUP BY FORMAT(c.createdAt,'yyyy-MM')
      ORDER BY mois
    `);

    res.json({
      success: true,
      data: { totaux: totaux.recordset[0], parImmeuble: parImmeuble.recordset, tendanceMensuelle: tendance.recordset, generatedAt: new Date() },
    });
  } catch (err) { next(err); }
};

const getRapportImpayes = async (req, res, next) => {
  try {
    const { immeubleId } = req.query;
    const pool = await getPool();

    const syndicRes = await pool.request().input('userId', sql.Int, req.user.id)
      .query('SELECT id FROM Syndics WHERE userId = @userId');
    const syndicId = syndicRes.recordset[0]?.id;

    let filter = `i.syndicId = ${syndicId} AND ch.statut IN ('unpaid','partially_paid')`;
    if (immeubleId) filter += ` AND i.id = ${immeubleId}`;

    const result = await pool.request().query(`
      SELECT h.nom, h.prenom, h.appartement, h.type AS habitantType,
             i.nom AS immeubleNom, u.email,
             c.nom AS chargeNom, c.dateEcheance,
             ch.montantDu, ch.montantPaye,
             (ch.montantDu - ch.montantPaye) AS montantRestant,
             ch.statut,
             DATEDIFF(DAY, c.dateEcheance, GETDATE()) AS joursRetard
      FROM ChargeHabitants ch
      INNER JOIN Charges   c ON ch.chargeId   = c.id
      INNER JOIN Immeubles i ON c.immeubleId  = i.id
      INNER JOIN Habitants h ON ch.habitantId = h.id
      INNER JOIN Users     u ON h.userId      = u.id
      WHERE ${filter}
      ORDER BY joursRetard DESC
    `);

    res.json({ success: true, data: result.recordset, total: result.recordset.length });
  } catch (err) { next(err); }
};

module.exports = { getRapportFinancier, getRapportImpayes };
