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
        .query(`INSERT INTO Syndics (userId,nom,prenom,telephone,adresse)
                OUTPUT INSERTED.id VALUES (@userId,@nom,@prenom,@telephone,@adresse)`);
      syndicId = r.recordset[0]?.id;
    } else {
      const r = await pool.request()
        .input('email', sql.NVarChar, 'syndic@syndic.com')
        .query(`SELECT s.id FROM Syndics s INNER JOIN Users u ON s.userId=u.id WHERE u.email=@email`);
      syndicId = r.recordset[0]?.id;
    }
    console.log('  ✅ Syndic         → syndic@syndic.com / Syndic@1234');

    // ── Immeuble ──────────────────────────────────────────────────
    const immRes = await pool.request()
      .input('syndicId',           sql.Int,      syndicId)
      .input('nom',                sql.NVarChar, 'Résidence Al Nour')
      .input('adresse',            sql.NVarChar, '12 Rue Ibn Battouta')
      .input('ville',              sql.NVarChar, 'Casablanca')
      .input('nombreAppartements', sql.Int,      12)
      .query(`INSERT INTO Immeubles (syndicId,nom,adresse,ville,nombreAppartements)
              OUTPUT INSERTED.id VALUES (@syndicId,@nom,@adresse,@ville,@nombreAppartements)`);
    const immeubleId = immRes.recordset[0]?.id;
    console.log('  ✅ Immeuble       → Résidence Al Nour (Casablanca)');

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
          .input('userId',     sql.Int,      userId)
          .input('type',       sql.NVarChar, 'proprietaire')
          .input('nom',        sql.NVarChar, o.nom)
          .input('prenom',     sql.NVarChar, o.prenom)
          .input('telephone',  sql.NVarChar, o.tel)
          .input('immeubleId', sql.Int,      immeubleId)
          .input('appartement',sql.NVarChar, o.appt)
          .query(`INSERT INTO Habitants (userId,type,nom,prenom,telephone,immeubleId,appartement)
                  OUTPUT INSERTED.id VALUES (@userId,@type,@nom,@prenom,@telephone,@immeubleId,@appartement)`);
        propHabitantIds.push(r.recordset[0]?.id);
      }
    }
    console.log('  ✅ Propriétaires  → prop1/prop2/prop3@syndic.com / Prop@1234');

    // ── Habitants — Locataires ────────────────────────────────────
    const locData = [
      { email: 'loc1@syndic.com', nom: 'Tazi',   prenom: 'Youssef', appt: 'C1', tel: '+212600000005', propIdx: 0 },
      { email: 'loc2@syndic.com', nom: 'Chaoui', prenom: 'Nadia',   appt: 'C2', tel: '+212600000006', propIdx: 1 },
    ];

    for (const t of locData) {
      const userId = await insertUser(pool, t.email, 'Loc@1234', 'locataire');
      if (userId) {
        await pool.request()
          .input('userId',         sql.Int,      userId)
          .input('type',           sql.NVarChar, 'locataire')
          .input('nom',            sql.NVarChar, t.nom)
          .input('prenom',         sql.NVarChar, t.prenom)
          .input('telephone',      sql.NVarChar, t.tel)
          .input('immeubleId',     sql.Int,      immeubleId)
          .input('appartement',    sql.NVarChar, t.appt)
          .input('proprietaireId', sql.Int,      propHabitantIds[t.propIdx])
          .input('dateEntree',     sql.Date,     '2025-01-01')
          .query(`INSERT INTO Habitants (userId,type,nom,prenom,telephone,immeubleId,appartement,proprietaireId,dateEntree)
                  VALUES (@userId,@type,@nom,@prenom,@telephone,@immeubleId,@appartement,@proprietaireId,@dateEntree)`);
      }
    }
    console.log('  ✅ Locataires     → loc1/loc2@syndic.com / Loc@1234');

    // ── Charges ──────────────────────────────────────────────────
    // Each charge template is inserted once per habitant in the immeuble
    // (mirrors the real createCharge API behaviour)
    const chargeTemplates = [
      { nom: 'Charges communes Jan 2026', description: 'Entretien parties communes', montant: 850.00,  dateEcheance: '2026-01-31', type: 'charges_communes' },
      { nom: 'Charges eau & électricité', description: 'Consommation T1 2026',       montant: 320.00,  dateEcheance: '2026-03-31', type: 'eau_electricite'  },
    ];

    // Fetch all habitants of the immeuble
    const allHabitants = await pool.request()
      .input('immeubleId', sql.Int, immeubleId)
      .query('SELECT id FROM Habitants WHERE immeubleId = @immeubleId');

    let chargeCount = 0;
    for (const tmpl of chargeTemplates) {
      for (const h of allHabitants.recordset) {
        await pool.request()
          .input('immeubleId',  sql.Int,           immeubleId)
          .input('habitantId',  sql.Int,           h.id)
          .input('nom',         sql.NVarChar,      tmpl.nom)
          .input('description', sql.NVarChar,      tmpl.description)
          .input('montant',     sql.Decimal(10,2), tmpl.montant)
          .input('dateEcheance',sql.Date,          tmpl.dateEcheance)
          .input('type',        sql.NVarChar,      tmpl.type)
          .query(`INSERT INTO Charges (immeubleId,habitantId,nom,description,montant,dateEcheance,type)
                  VALUES (@immeubleId,@habitantId,@nom,@description,@montant,@dateEcheance,@type)`);
        chargeCount++;
      }
    }
    console.log(`  ✅ Charges        → ${chargeCount} charges created (${chargeTemplates.length} templates × ${allHabitants.recordset.length} habitants)`);

    // ── Assemblée ─────────────────────────────────────────────────
    await pool.request()
      .input('immeubleId',  sql.Int,      immeubleId)
      .input('syndicId',    sql.Int,      syndicId)
      .input('titre',       sql.NVarChar, 'Assemblée Générale Ordinaire 2026')
      .input('description', sql.NVarChar, 'Réunion annuelle des copropriétaires')
      .input('dateAG',      sql.DateTime, new Date('2026-05-15T10:00:00'))
      .input('lieu',        sql.NVarChar, 'Salle de réunion - RDC')
      .input('ordreJour',   sql.NVarChar, '1. Approbation des comptes\n2. Budget prévisionnel\n3. Travaux à prévoir')
      .query(`INSERT INTO AssembleesGenerales (immeubleId,syndicId,titre,description,dateAG,lieu,ordreJour)
              VALUES (@immeubleId,@syndicId,@titre,@description,@dateAG,@lieu,@ordreJour)`);
    console.log('  ✅ Assemblée      → AGO 2026 planifiée');

    // ── Summary ───────────────────────────────────────────────────
    console.log('\n🎉 Seed completed!\n');
    console.log('╔══════════════════════════════════════════════════════════════╗');
    console.log('║                     📋 TEST ACCOUNTS                        ║');
    console.log('╠══════════════════════════════════════════════════════════════╣');
    console.log('║  Role           Email                    Password           ║');
    console.log('║  ────────────   ──────────────────────   ────────────────   ║');
    console.log('║  Syndic         syndic@syndic.com        Syndic@1234        ║');
    console.log('║  Propriétaire   prop1@syndic.com         Prop@1234          ║');
    console.log('║  Propriétaire   prop2@syndic.com         Prop@1234          ║');
    console.log('║  Propriétaire   prop3@syndic.com         Prop@1234          ║');
    console.log('║  Locataire      loc1@syndic.com          Loc@1234           ║');
    console.log('║  Locataire      loc2@syndic.com          Loc@1234           ║');
    console.log('╚══════════════════════════════════════════════════════════════╝');
    process.exit(0);
  } catch (err) {
    console.error('❌ Seed failed:', err.message);
    process.exit(1);
  }
};

seed();
