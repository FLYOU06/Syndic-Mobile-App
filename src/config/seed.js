require('dotenv').config();
const bcrypt = require('bcryptjs');
const { getPool, sql } = require('./database');

const insertUser = async (pool, email, password, role) => {
  const hashed = await bcrypt.hash(password, 12);
  const r = await pool.request()
    .input('email',    sql.NVarChar, email)
    .input('password', sql.NVarChar, hashed)
    .input('role',     sql.NVarChar, role)
    .query(`
      IF NOT EXISTS (SELECT 1 FROM Users WHERE email = @email)
        INSERT INTO Users (email, password, role) OUTPUT INSERTED.id VALUES (@email, @password, @role)
      ELSE
        SELECT id FROM Users WHERE email = @email
    `);
  return r.recordset[0]?.id;
};

const seed = async () => {
  try {
    const pool = await getPool();
    console.log('🌱 Seeding database...\n');

    // ── Syndic ────────────────────────────────────────────────────
    const syndicUserId = await insertUser(pool, 'syndic@syndic.com', 'Syndic@1234', 'syndic');
    let syndicId = null;

    if (syndicUserId) {
      const r = await pool.request()
        .input('userId',    sql.Int,      syndicUserId)
        .input('nom',       sql.NVarChar, 'Alami')
        .input('prenom',    sql.NVarChar, 'Karim')
        .input('telephone', sql.NVarChar, '+212600000001')
        .input('adresse',   sql.NVarChar, '5 Rue Hassan II, Casablanca')
        .query(`
          IF NOT EXISTS (SELECT 1 FROM Syndics WHERE userId = @userId)
            INSERT INTO Syndics (userId, nom, prenom, telephone, adresse)
            OUTPUT INSERTED.id VALUES (@userId, @nom, @prenom, @telephone, @adresse)
          ELSE
            SELECT id FROM Syndics WHERE userId = @userId
        `);
      syndicId = r.recordset[0]?.id;
    }
    console.log('  ✅ Syndic       → syndic@syndic.com / Syndic@1234');

    // ── Immeuble ──────────────────────────────────────────────────
    const immRes = await pool.request()
      .input('syndicId',           sql.Int,      syndicId)
      .input('nom',                sql.NVarChar, 'Résidence Al Nour')
      .input('adresse',            sql.NVarChar, '12 Rue Ibn Battouta')
      .input('ville',              sql.NVarChar, 'Casablanca')
      .input('nombreAppartements', sql.Int,      10)
      .query(`
        IF NOT EXISTS (SELECT 1 FROM Immeubles WHERE nom = 'Résidence Al Nour' AND syndicId = @syndicId)
          INSERT INTO Immeubles (syndicId, nom, adresse, ville, nombreAppartements)
          OUTPUT INSERTED.id VALUES (@syndicId, @nom, @adresse, @ville, @nombreAppartements)
        ELSE
          SELECT id FROM Immeubles WHERE nom = 'Résidence Al Nour' AND syndicId = @syndicId
      `);
    const immeubleId = immRes.recordset[0]?.id;
    console.log('  ✅ Immeuble    → Résidence Al Nour, Casablanca');

    // ── Habitants — Propriétaires ─────────────────────────────────
    const propData = [
      { email: 'prop1@syndic.com', nom: 'Benali',  prenom: 'Sara',  appt: 'A1', tel: '+212600000002' },
      { email: 'prop2@syndic.com', nom: 'Fassi',   prenom: 'Omar',  appt: 'A2', tel: '+212600000003' },
      { email: 'prop3@syndic.com', nom: 'Idrissi', prenom: 'Leila', appt: 'B1', tel: '+212600000004' },
    ];

    const propHabitantIds = [];
    for (const o of propData) {
      const userId = await insertUser(pool, o.email, 'Prop@1234', 'proprietaire');
      if (userId) {
        const r = await pool.request()
          .input('userId',      sql.Int,      userId)
          .input('type',        sql.NVarChar, 'proprietaire')
          .input('nom',         sql.NVarChar, o.nom)
          .input('prenom',      sql.NVarChar, o.prenom)
          .input('telephone',   sql.NVarChar, o.tel)
          .input('immeubleId',  sql.Int,      immeubleId)
          .input('appartement', sql.NVarChar, o.appt)
          .query(`
            IF NOT EXISTS (SELECT 1 FROM Habitants WHERE userId = @userId)
              INSERT INTO Habitants (userId, type, nom, prenom, telephone, immeubleId, appartement)
              OUTPUT INSERTED.id VALUES (@userId, @type, @nom, @prenom, @telephone, @immeubleId, @appartement)
            ELSE
              SELECT id FROM Habitants WHERE userId = @userId
          `);
        propHabitantIds.push(r.recordset[0]?.id);
      }
    }
    console.log('  ✅ Propriétaires → prop1/prop2/prop3@syndic.com / Prop@1234');

    // ── Habitants — Locataires ────────────────────────────────────
    const locData = [
      { email: 'loc1@syndic.com', nom: 'Tazi',   prenom: 'Youssef', appt: 'C1', tel: '+212600000005', propIdx: 0 },
      { email: 'loc2@syndic.com', nom: 'Chaoui', prenom: 'Nadia',   appt: 'C2', tel: '+212600000006', propIdx: 1 },
    ];

    const locHabitantIds = [];
    for (const t of locData) {
      const userId = await insertUser(pool, t.email, 'Loc@1234', 'locataire');
      if (userId) {
        const r = await pool.request()
          .input('userId',         sql.Int,      userId)
          .input('type',           sql.NVarChar, 'locataire')
          .input('nom',            sql.NVarChar, t.nom)
          .input('prenom',         sql.NVarChar, t.prenom)
          .input('telephone',      sql.NVarChar, t.tel)
          .input('immeubleId',     sql.Int,      immeubleId)
          .input('appartement',    sql.NVarChar, t.appt)
          .input('proprietaireId', sql.Int,      propHabitantIds[t.propIdx])
          .input('dateEntree',     sql.Date,     '2025-01-01')
          .query(`
            IF NOT EXISTS (SELECT 1 FROM Habitants WHERE userId = @userId)
              INSERT INTO Habitants (userId, type, nom, prenom, telephone, immeubleId, appartement, proprietaireId, dateEntree)
              OUTPUT INSERTED.id VALUES (@userId, @type, @nom, @prenom, @telephone, @immeubleId, @appartement, @proprietaireId, @dateEntree)
            ELSE
              SELECT id FROM Habitants WHERE userId = @userId
          `);
        locHabitantIds.push(r.recordset[0]?.id);
      }
    }
    console.log('  ✅ Locataires   → loc1/loc2@syndic.com / Loc@1234');

    // ── All habitant IDs in this immeuble ─────────────────────────
    const allHabitantIds = [...propHabitantIds, ...locHabitantIds].filter(Boolean);
    const totalHabitants = allHabitantIds.length;

    // ── Charge 1 — Charges communes (assigned to all habitants) ───
    const charge1Res = await pool.request()
      .input('immeubleId',   sql.Int,           immeubleId)
      .input('nom',          sql.NVarChar,      'Charges communes Avril 2026')
      .input('description',  sql.NVarChar,      'Entretien ascenseur, nettoyage parties communes')
      .input('montantTotal', sql.Decimal(10,2), 5000.00)
      .input('dateEcheance', sql.Date,          '2026-04-30')
      .input('type',         sql.NVarChar,      'charges_communes')
      .query(`
        IF NOT EXISTS (SELECT 1 FROM Charges WHERE nom = 'Charges communes Avril 2026' AND immeubleId = @immeubleId)
          INSERT INTO Charges (immeubleId, nom, description, montantTotal, dateEcheance, type)
          OUTPUT INSERTED.id VALUES (@immeubleId, @nom, @description, @montantTotal, @dateEcheance, @type)
        ELSE
          SELECT id FROM Charges WHERE nom = 'Charges communes Avril 2026' AND immeubleId = @immeubleId
      `);
    const charge1Id = charge1Res.recordset[0]?.id;

    // Assign charge 1 to every habitant (split equally)
    const montantParHabitant1 = parseFloat((5000 / totalHabitants).toFixed(2));
    for (const hId of allHabitantIds) {
      await pool.request()
        .input('chargeId',   sql.Int,           charge1Id)
        .input('habitantId', sql.Int,           hId)
        .input('montantDu',  sql.Decimal(10,2), montantParHabitant1)
        .query(`
          IF NOT EXISTS (SELECT 1 FROM ChargeHabitants WHERE chargeId=@chargeId AND habitantId=@habitantId)
            INSERT INTO ChargeHabitants (chargeId, habitantId, montantDu) VALUES (@chargeId, @habitantId, @montantDu)
        `);
    }

    // Mark prop1 as PAID
    if (propHabitantIds[0]) {
      await pool.request()
        .input('chargeId',    sql.Int,           charge1Id)
        .input('habitantId',  sql.Int,           propHabitantIds[0])
        .input('montantPaye', sql.Decimal(10,2), montantParHabitant1)
        .query(`UPDATE ChargeHabitants SET montantPaye=@montantPaye, statut='paid',
                datePaiement=GETDATE(), modePaiement='virement', updatedAt=GETDATE()
                WHERE chargeId=@chargeId AND habitantId=@habitantId`);
    }

    // Mark prop2 as PARTIALLY PAID
    if (propHabitantIds[1]) {
      const partial = parseFloat((montantParHabitant1 / 2).toFixed(2));
      await pool.request()
        .input('chargeId',    sql.Int,           charge1Id)
        .input('habitantId',  sql.Int,           propHabitantIds[1])
        .input('montantPaye', sql.Decimal(10,2), partial)
        .query(`UPDATE ChargeHabitants SET montantPaye=@montantPaye, statut='partially_paid',
                datePaiement=GETDATE(), modePaiement='especes', updatedAt=GETDATE()
                WHERE chargeId=@chargeId AND habitantId=@habitantId`);
    }
    console.log(`  ✅ Charge 1     → "Charges communes Avril 2026" (${totalHabitants} habitants, ${montantParHabitant1} MAD each)`);
    console.log('                  → prop1: paid | prop2: partially_paid | others: unpaid');

    // ── Charge 2 — Eau & Électricité ──────────────────────────────
    const charge2Res = await pool.request()
      .input('immeubleId',   sql.Int,           immeubleId)
      .input('nom',          sql.NVarChar,      'Eau & Électricité Mai 2026')
      .input('description',  sql.NVarChar,      'Facture eau et électricité parties communes')
      .input('montantTotal', sql.Decimal(10,2), 1200.00)
      .input('dateEcheance', sql.Date,          '2026-05-15')
      .input('type',         sql.NVarChar,      'eau_electricite')
      .query(`
        IF NOT EXISTS (SELECT 1 FROM Charges WHERE nom = 'Eau & Électricité Mai 2026' AND immeubleId = @immeubleId)
          INSERT INTO Charges (immeubleId, nom, description, montantTotal, dateEcheance, type)
          OUTPUT INSERTED.id VALUES (@immeubleId, @nom, @description, @montantTotal, @dateEcheance, @type)
        ELSE
          SELECT id FROM Charges WHERE nom = 'Eau & Électricité Mai 2026' AND immeubleId = @immeubleId
      `);
    const charge2Id = charge2Res.recordset[0]?.id;

    const montantParHabitant2 = parseFloat((1200 / totalHabitants).toFixed(2));
    for (const hId of allHabitantIds) {
      await pool.request()
        .input('chargeId',   sql.Int,           charge2Id)
        .input('habitantId', sql.Int,           hId)
        .input('montantDu',  sql.Decimal(10,2), montantParHabitant2)
        .query(`
          IF NOT EXISTS (SELECT 1 FROM ChargeHabitants WHERE chargeId=@chargeId AND habitantId=@habitantId)
            INSERT INTO ChargeHabitants (chargeId, habitantId, montantDu) VALUES (@chargeId, @habitantId, @montantDu)
        `);
    }
    console.log(`  ✅ Charge 2     → "Eau & Électricité Mai 2026" (all unpaid)`);

    // ── Assemblée Générale ────────────────────────────────────────
    await pool.request()
      .input('immeubleId',  sql.Int,      immeubleId)
      .input('syndicId',    sql.Int,      syndicId)
      .input('titre',       sql.NVarChar, 'AGO 2026 — Résidence Al Nour')
      .input('dateAG',      sql.DateTime, new Date('2026-05-20T10:00:00'))
      .input('lieu',        sql.NVarChar, 'Salle de réunion — RDC')
      .input('ordreJour',   sql.NVarChar, '1. Approbation des comptes 2025\n2. Budget prévisionnel 2026\n3. Travaux ascenseur')
      .query(`
        IF NOT EXISTS (SELECT 1 FROM AssembleesGenerales WHERE titre = 'AGO 2026 — Résidence Al Nour')
          INSERT INTO AssembleesGenerales (immeubleId, syndicId, titre, dateAG, lieu, ordreJour)
          VALUES (@immeubleId, @syndicId, @titre, @dateAG, @lieu, @ordreJour)
      `);
    console.log('  ✅ Assemblée   → AGO 2026 planifiée le 20/05/2026');

    // ── Print summary ─────────────────────────────────────────────
    console.log('\n🎉 Seed completed!\n');
    console.log('╔══════════════════════════════════════════════════════════════════╗');
    console.log('║                       📋 TEST ACCOUNTS                          ║');
    console.log('╠══════════════════════════════════════════════════════════════════╣');
    console.log('║  Role           Email                    Password               ║');
    console.log('║  ────────────   ──────────────────────   ──────────────────     ║');
    console.log('║  Syndic         syndic@syndic.com        Syndic@1234            ║');
    console.log('║  Propriétaire   prop1@syndic.com         Prop@1234  (paid)      ║');
    console.log('║  Propriétaire   prop2@syndic.com         Prop@1234  (partial)   ║');
    console.log('║  Propriétaire   prop3@syndic.com         Prop@1234  (unpaid)    ║');
    console.log('║  Locataire      loc1@syndic.com          Loc@1234   (unpaid)    ║');
    console.log('║  Locataire      loc2@syndic.com          Loc@1234   (unpaid)    ║');
    console.log('╚══════════════════════════════════════════════════════════════════╝');

    process.exit(0);
  } catch (err) {
    console.error('❌ Seed failed:', err.message);
    process.exit(1);
  }
};

seed();
