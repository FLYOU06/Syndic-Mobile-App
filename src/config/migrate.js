require('dotenv').config();
const { getPool, sql } = require('./database');

const migrate = async () => {
  try {
    const pool = await getPool();
    console.log('🔄 Running migrations...');

    // ─── USERS ─────────────────────────────────────────────────────
    await pool.request().query(`
      IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Users' AND xtype='U')
      CREATE TABLE Users (
        id        INT IDENTITY(1,1) PRIMARY KEY,
        email     NVARCHAR(255) NOT NULL UNIQUE,
        password  NVARCHAR(255) NOT NULL,
        role      NVARCHAR(50)  NOT NULL CHECK (role IN ('syndic','proprietaire','locataire')),
        isActive  BIT           NOT NULL DEFAULT 1,
        createdAt DATETIME      NOT NULL DEFAULT GETDATE(),
        updatedAt DATETIME      NOT NULL DEFAULT GETDATE()
      )
    `);
    console.log('  ✅ Users');

    // ─── SYNDICS ───────────────────────────────────────────────────
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

    // ─── IMMEUBLES ─────────────────────────────────────────────────
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

    // ─── HABITANTS ─────────────────────────────────────────────────
    // Merges Proprietaires + Locataires into one table.
    // type = 'proprietaire' | 'locataire'
    // proprietaireId is only set when type = 'locataire' (links tenant to their owner)
    await pool.request().query(`
      IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Habitants' AND xtype='U')
      CREATE TABLE Habitants (
        id              INT IDENTITY(1,1) PRIMARY KEY,
        userId          INT NOT NULL FOREIGN KEY REFERENCES Users(id) ON DELETE CASCADE,
        type            NVARCHAR(50) NOT NULL CHECK (type IN ('proprietaire','locataire')),
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
    console.log('  ✅ Habitants (proprietaires + locataires merged)');

    // ─── CHARGES ───────────────────────────────────────────────────
    await pool.request().query(`
      IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Charges' AND xtype='U')
      CREATE TABLE Charges (
        id          INT IDENTITY(1,1) PRIMARY KEY,
        immeubleId  INT NOT NULL FOREIGN KEY REFERENCES Immeubles(id),
        habitantId  INT FOREIGN KEY REFERENCES Habitants(id),
        nom         NVARCHAR(150) NOT NULL,
        description NVARCHAR(255),
        montant     DECIMAL(10,2) NOT NULL,
        dateEcheance DATE NOT NULL,
        statut      NVARCHAR(50) NOT NULL DEFAULT 'en_attente'
                    CHECK (statut IN ('en_attente','paye','en_retard','annule')),
        type        NVARCHAR(100),
        createdAt   DATETIME NOT NULL DEFAULT GETDATE(),
        updatedAt   DATETIME NOT NULL DEFAULT GETDATE()
      )
    `);
    console.log('  ✅ Charges');

    // ─── PAIEMENTS ─────────────────────────────────────────────────
    await pool.request().query(`
      IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Paiements' AND xtype='U')
      CREATE TABLE Paiements (
        id           INT IDENTITY(1,1) PRIMARY KEY,
        chargeId     INT NOT NULL FOREIGN KEY REFERENCES Charges(id),
        habitantId   INT NOT NULL FOREIGN KEY REFERENCES Habitants(id),
        montant      DECIMAL(10,2) NOT NULL,
        datePaiement DATETIME NOT NULL DEFAULT GETDATE(),
        modePaiement NVARCHAR(50) CHECK (modePaiement IN ('especes','virement','cheque','carte')),
        reference    NVARCHAR(100),
        createdAt    DATETIME NOT NULL DEFAULT GETDATE()
      )
    `);
    console.log('  ✅ Paiements');

    // ─── ASSEMBLEES GENERALES ──────────────────────────────────────
    await pool.request().query(`
      IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='AssembleesGenerales' AND xtype='U')
      CREATE TABLE AssembleesGenerales (
        id           INT IDENTITY(1,1) PRIMARY KEY,
        immeubleId   INT NOT NULL FOREIGN KEY REFERENCES Immeubles(id),
        syndicId     INT NOT NULL FOREIGN KEY REFERENCES Syndics(id),
        titre        NVARCHAR(255) NOT NULL,
        description  NVARCHAR(MAX),
        dateAG       DATETIME NOT NULL,
        lieu         NVARCHAR(255),
        statut       NVARCHAR(50) NOT NULL DEFAULT 'planifiee'
                     CHECK (statut IN ('planifiee','en_cours','terminee','annulee')),
        ordreJour    NVARCHAR(MAX),
        procesVerbal NVARCHAR(MAX),
        createdAt    DATETIME NOT NULL DEFAULT GETDATE(),
        updatedAt    DATETIME NOT NULL DEFAULT GETDATE()
      )
    `);
    console.log('  ✅ AssembleesGenerales');

    // ─── NOTIFICATIONS ─────────────────────────────────────────────
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

    // ─── RAPPORTS ──────────────────────────────────────────────────
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

    console.log('\n🎉 All migrations completed successfully!');
    process.exit(0);
  } catch (err) {
    console.error('❌ Migration failed:', err.message);
    process.exit(1);
  }
};

migrate();
