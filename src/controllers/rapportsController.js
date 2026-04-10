const { getPool, sql } = require('../config/database');

// GET /api/rapports/financier  — financial summary report
const getRapportFinancier = async (req, res, next) => {
  try {
    const { immeubleId, dateDebut, dateFin } = req.query;

    const pool = await getPool();

    const syndicResult = await pool.request()
      .input('userId', sql.Int, req.user.id)
      .query('SELECT id FROM Syndics WHERE userId = @userId');
    const syndicId = syndicResult.recordset[0]?.id;

    let immeubleFilter = `i.syndicId = ${syndicId}`;
    if (immeubleId) immeubleFilter += ` AND i.id = ${immeubleId}`;

    let dateFilter = '';
    if (dateDebut) dateFilter += ` AND c.createdAt >= '${dateDebut}'`;
    if (dateFin)   dateFilter += ` AND c.createdAt <= '${dateFin}'`;

    // Totals per status
    const totaux = await pool.request().query(`
      SELECT
        SUM(c.montant) AS totalCharges,
        SUM(CASE WHEN c.statut='paye' THEN c.montant ELSE 0 END) AS totalPercu,
        SUM(CASE WHEN c.statut IN('en_attente','en_retard') THEN c.montant ELSE 0 END) AS totalImpaye,
        COUNT(*) AS nombreCharges,
        SUM(CASE WHEN c.statut='paye' THEN 1 ELSE 0 END) AS nombrePaye,
        SUM(CASE WHEN c.statut IN('en_attente','en_retard') THEN 1 ELSE 0 END) AS nombreImpaye
      FROM Charges c
      INNER JOIN Immeubles i ON c.immeubleId = i.id
      WHERE ${immeubleFilter} ${dateFilter}
    `);

    // Per-immeuble breakdown
    const parImmeuble = await pool.request().query(`
      SELECT
        i.id, i.nom,
        COUNT(c.id) AS nombreCharges,
        SUM(c.montant) AS totalCharges,
        SUM(CASE WHEN c.statut='paye' THEN c.montant ELSE 0 END) AS totalPercu,
        SUM(CASE WHEN c.statut IN('en_attente','en_retard') THEN c.montant ELSE 0 END) AS totalImpaye
      FROM Charges c
      INNER JOIN Immeubles i ON c.immeubleId = i.id
      WHERE ${immeubleFilter} ${dateFilter}
      GROUP BY i.id, i.nom
    `);

    // Monthly trend (last 12 months)
    const tendance = await pool.request().query(`
      SELECT
        FORMAT(c.createdAt, 'yyyy-MM') AS mois,
        SUM(c.montant) AS totalCharges,
        SUM(CASE WHEN c.statut='paye' THEN c.montant ELSE 0 END) AS totalPercu
      FROM Charges c
      INNER JOIN Immeubles i ON c.immeubleId = i.id
      WHERE ${immeubleFilter}
        AND c.createdAt >= DATEADD(MONTH, -12, GETDATE())
      GROUP BY FORMAT(c.createdAt, 'yyyy-MM')
      ORDER BY mois
    `);

    // Save this report
    await pool.request()
      .input('syndicId',   sql.Int,      syndicId)
      .input('immeubleId', sql.Int,      immeubleId || null)
      .input('type',       sql.NVarChar, 'financier')
      .input('titre',      sql.NVarChar, `Rapport Financier - ${new Date().toLocaleDateString('fr-FR')}`)
      .input('dateDebut',  sql.Date,     dateDebut || null)
      .input('dateFin',    sql.Date,     dateFin || null)
      .input('donnees',    sql.NVarChar, JSON.stringify({ totaux: totaux.recordset[0] }))
      .query(`
        INSERT INTO Rapports (syndicId, immeubleId, type, titre, dateDebut, dateFin, donnees)
        VALUES (@syndicId, @immeubleId, @type, @titre, @dateDebut, @dateFin, @donnees)
      `);

    res.json({
      success: true,
      data: {
        totaux: totaux.recordset[0],
        parImmeuble: parImmeuble.recordset,
        tendanceMensuelle: tendance.recordset,
        generatedAt: new Date(),
      },
    });
  } catch (err) {
    next(err);
  }
};

// GET /api/rapports/impayes  — unpaid report
const getRapportImpayes = async (req, res, next) => {
  try {
    const { immeubleId } = req.query;
    const pool = await getPool();

    const syndicResult = await pool.request()
      .input('userId', sql.Int, req.user.id)
      .query('SELECT id FROM Syndics WHERE userId = @userId');
    const syndicId = syndicResult.recordset[0]?.id;

    let filter = `i.syndicId = ${syndicId} AND c.statut IN('en_attente','en_retard')`;
    if (immeubleId) filter += ` AND i.id = ${immeubleId}`;

    const result = await pool.request().query(`
      SELECT
        p.nom, p.prenom, p.appartement,
        i.nom AS immeubleNom,
        c.description, c.montant, c.dateEcheance, c.statut,
        DATEDIFF(DAY, c.dateEcheance, GETDATE()) AS joursRetard
      FROM Charges c
      INNER JOIN Immeubles i ON c.immeubleId = i.id
      INNER JOIN Proprietaires p ON c.proprietaireId = p.id
      WHERE ${filter}
      ORDER BY joursRetard DESC
    `);

    res.json({ success: true, data: result.recordset, total: result.recordset.length });
  } catch (err) {
    next(err);
  }
};

// GET /api/rapports/history
const getRapportHistory = async (req, res, next) => {
  try {
    const pool = await getPool();
    const syndicResult = await pool.request()
      .input('userId', sql.Int, req.user.id)
      .query('SELECT id FROM Syndics WHERE userId = @userId');
    const syndicId = syndicResult.recordset[0]?.id;

    const result = await pool.request()
      .input('syndicId', sql.Int, syndicId)
      .query('SELECT id, type, titre, dateDebut, dateFin, createdAt FROM Rapports WHERE syndicId=@syndicId ORDER BY createdAt DESC');

    res.json({ success: true, data: result.recordset });
  } catch (err) {
    next(err);
  }
};

module.exports = { getRapportFinancier, getRapportImpayes, getRapportHistory };
