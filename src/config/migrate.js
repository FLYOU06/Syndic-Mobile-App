require('dotenv').config();
const { getPool, sql } = require('./database');

const migrate = async () => {
  try {
    const pool = await getPool();
    console.log('🔄 Running migrations...\n');

    // ── USERS ────────────────────────────────────────────────────────
    await pool.request().query(`
      IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Users' AND xtype='U')
      CREATE TABLE Users (
        id        INT IDENTITY(1,1) PRIMARY KEY,
        email     NVARCHAR(255) NOT NULL UNIQUE,
        password  NVARCHAR(255) NOT NULL,
        role      NVARCHAR(20)  NOT NULL CHECK (role IN ('syndic','proprietaire','locataire')),
        isActive  BIT           NOT NULL DEFAULT 1,
        createdAt DATETIME      NOT NULL DEFAULT GETDATE(),
        updatedAt DATETIME      NOT NULL DEFAULT GETDATE()
      )
    `);
    console.log('  ✅ Users');

    // ── SYNDICS ──────────────────────────────────────────────────────
    await pool.request().query(`
      IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Syndics' AND xtype='U')
      CREATE TABLE Syndics (
        id        INT IDENTITY(1,1) PRIMARY KEY,
        userId    INT NOT NULL FOREIGN KEY REFERENCES Users(id) ON DELETE CASCADE,
        nom       NVARCHAR(100) NOT NULL,
        prenom    NVARCHAR(100) NOT NULL,
        telephone NVARCHAR(20),
        adresse   NVARCHAR(255),
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        updatedAt DATETIME NOT NULL DEFAULT GETDATE()
      )
    `);
    console.log('  ✅ Syndics');

    // ── IMMEUBLES ────────────────────────────────────────────────────
    await pool.request().query(`
      IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Immeubles' AND xtype='U')
      CREATE TABLE Immeubles (
        id                 INT IDENTITY(1,1) PRIMARY KEY,
        syndicId           INT NOT NULL FOREIGN KEY REFERENCES Syndics(id),
        nom                NVARCHAR(150) NOT NULL,
        adresse            NVARCHAR(255) NOT NULL,
        ville              NVARCHAR(100),
        nombreAppartements INT DEFAULT 0,
        createdAt          DATETIME NOT NULL DEFAULT GETDATE(),
        updatedAt          DATETIME NOT NULL DEFAULT GETDATE()
      )
    `);
    console.log('  ✅ Immeubles');

    // ── HABITANTS ────────────────────────────────────────────────────
    // Merges Proprietaires + Locataires into one table
    // proprietaireId (self-ref) is only set when type = 'locataire'
    await pool.request().query(`
      IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Habitants' AND xtype='U')
      CREATE TABLE Habitants (
        id              INT IDENTITY(1,1) PRIMARY KEY,
        userId          INT NOT NULL FOREIGN KEY REFERENCES Users(id) ON DELETE CASCADE,
        type            NVARCHAR(20) NOT NULL CHECK (type IN ('proprietaire','locataire')),
        nom             NVARCHAR(100) NOT NULL,
        prenom          NVARCHAR(100) NOT NULL,
        telephone       NVARCHAR(20),
        immeubleId      INT FOREIGN KEY REFERENCES Immeubles(id),
        appartement     NVARCHAR(50),
        proprietaireId  INT FOREIGN KEY REFERENCES Habitants(id),
        dateEntree      DATE,
        dateSortie      DATE,
        createdAt       DATETIME NOT NULL DEFAULT GETDATE(),
        updatedAt       DATETIME NOT NULL DEFAULT GETDATE()
      )
    `);
    console.log('  ✅ Habitants (proprietaires + locataires)');

    // ── CHARGES ──────────────────────────────────────────────────────
    // A charge belongs to an immeuble (not to a single habitant).
    // When created, it is automatically assigned to every habitant
    // in that immeuble via the ChargeHabitants pivot table below.
    await pool.request().query(`
      IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Charges' AND xtype='U')
      CREATE TABLE Charges (
        id           INT IDENTITY(1,1) PRIMARY KEY,
        immeubleId   INT NOT NULL FOREIGN KEY REFERENCES Immeubles(id),
        nom          NVARCHAR(150) NOT NULL,
        description  NVARCHAR(255),
        montantTotal DECIMAL(10,2) NOT NULL,
        dateEcheance DATE NOT NULL,
        type         NVARCHAR(100),
        createdAt    DATETIME NOT NULL DEFAULT GETDATE(),
        updatedAt    DATETIME NOT NULL DEFAULT GETDATE()
      )
    `);
    console.log('  ✅ Charges');

    // ── CHARGE_HABITANTS (pivot) ──────────────────────────────────────
    // One row per (charge, habitant) pair.
    // statut: unpaid | partially_paid | paid
    await pool.request().query(`
      IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='ChargeHabitants' AND xtype='U')
      CREATE TABLE ChargeHabitants (
        id             INT IDENTITY(1,1) PRIMARY KEY,
        chargeId       INT NOT NULL FOREIGN KEY REFERENCES Charges(id) ON DELETE CASCADE,
        habitantId     INT NOT NULL FOREIGN KEY REFERENCES Habitants(id),
        montantDu      DECIMAL(10,2) NOT NULL,
        montantPaye    DECIMAL(10,2) NOT NULL DEFAULT 0,
        statut         NVARCHAR(20)  NOT NULL DEFAULT 'unpaid'
                       CHECK (statut IN ('unpaid','partially_paid','paid')),
        datePaiement   DATETIME,
        modePaiement   NVARCHAR(50) CHECK (modePaiement IN ('especes','virement','cheque','carte')),
        reference      NVARCHAR(100),
        createdAt      DATETIME NOT NULL DEFAULT GETDATE(),
        updatedAt      DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT UQ_ChargeHabitant UNIQUE (chargeId, habitantId)
      )
    `);
    console.log('  ✅ ChargeHabitants (pivot: per-resident payment status)');

    // ── NOTIFICATIONS ────────────────────────────────────────────────
    await pool.request().query(`
      IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Notifications' AND xtype='U')
      CREATE TABLE Notifications (
        id        INT IDENTITY(1,1) PRIMARY KEY,
        userId    INT NOT NULL FOREIGN KEY REFERENCES Users(id) ON DELETE CASCADE,
        titre     NVARCHAR(255) NOT NULL,
        message   NVARCHAR(MAX) NOT NULL,
        type      NVARCHAR(50) CHECK (type IN ('info','alerte','paiement','assemblee','charge')),
        isRead    BIT NOT NULL DEFAULT 0,
        createdAt DATETIME NOT NULL DEFAULT GETDATE()
      )
    `);
    console.log('  ✅ Notifications');

    // ── ASSEMBLEES_GENERALES ─────────────────────────────────────────
    await pool.request().query(`
      IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='AssembleesGenerales' AND xtype='U')
      CREATE TABLE AssembleesGenerales (
        id           INT IDENTITY(1,1) PRIMARY KEY,
        immeubleId   INT NOT NULL FOREIGN KEY REFERENCES Immeubles(id),
        syndicId     INT NOT NULL FOREIGN KEY REFERENCES Syndics(id),
        titre        NVARCHAR(255) NOT NULL,
        type         NVARCHAR(20)  NOT NULL DEFAULT 'ordinaire'
                     CHECK (type IN ('ordinaire','extraordinaire')),
        description  NVARCHAR(MAX),
        dateAG       DATE NOT NULL,
        heure        NVARCHAR(10),
        lieu         NVARCHAR(255),
        statut       NVARCHAR(20)  NOT NULL DEFAULT 'planifiee'
                     CHECK (statut IN ('planifiee','en_cours','terminee','annulee')),
        ordreJour    NVARCHAR(MAX),
        procesVerbal NVARCHAR(MAX),
        presents     INT NOT NULL DEFAULT 0,
        absents      INT NOT NULL DEFAULT 0,
        procurations INT NOT NULL DEFAULT 0,
        pvGenere     BIT NOT NULL DEFAULT 0,
        convocation  NVARCHAR(MAX),
        createdAt    DATETIME NOT NULL DEFAULT GETDATE(),
        updatedAt    DATETIME NOT NULL DEFAULT GETDATE()
      )
    `);
    console.log('  ✅ AssembleesGenerales');

    // ── RAPPORTS ─────────────────────────────────────────────────────
    await pool.request().query(`
      IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Rapports' AND xtype='U')
      CREATE TABLE Rapports (
        id         INT IDENTITY(1,1) PRIMARY KEY,
        syndicId   INT NOT NULL FOREIGN KEY REFERENCES Syndics(id),
        immeubleId INT FOREIGN KEY REFERENCES Immeubles(id),
        type       NVARCHAR(100) NOT NULL,
        titre      NVARCHAR(255) NOT NULL,
        dateDebut  DATE,
        dateFin    DATE,
        donnees    NVARCHAR(MAX),
        createdAt  DATETIME NOT NULL DEFAULT GETDATE()
      )
    `);
    console.log('  ✅ Rapports');

    console.log('\n🎉 All migrations completed!\n');
    process.exit(0);
  } catch (err) {
    console.error('❌ Migration failed:', err.message);
    process.exit(1);
  }
};

migrate();
