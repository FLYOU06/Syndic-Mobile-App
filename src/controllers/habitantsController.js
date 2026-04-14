const bcrypt = require('bcryptjs');
const { getPool, sql } = require('../config/database');
const emailService = require('../services/emailService');

// ── helper: generate a random password ──────────────────────────────
const generatePassword = () => {
  const chars = 'ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789@#$!';
  let pw = '';
  for (let i = 0; i < 10; i++) pw += chars[Math.floor(Math.random() * chars.length)];
  return pw;
};

// ── POST /api/habitants  (syndic creates a resident) ─────────────────
// No public registration — only the syndic can create accounts.
const createHabitant = async (req, res, next) => {
  try {
    const {
      email, password,           // password optional — auto-generated if omitted
      type,                      // 'proprietaire' | 'locataire'
      nom, prenom, telephone,
      immeubleId, appartement,
      proprietaireId,            // locataire only
      dateEntree, dateSortie,
      sendEmail,                 // boolean — send credentials by email
    } = req.body;

    if (!email || !type || !nom || !prenom || !immeubleId)
      return res.status(400).json({ success: false, message: 'email, type, nom, prenom and immeubleId are required.' });

    if (!['proprietaire', 'locataire'].includes(type))
      return res.status(400).json({ success: false, message: 'type must be "proprietaire" or "locataire".' });

    const pool = await getPool();

    // Verify email uniqueness
    const exists = await pool.request()
      .input('email', sql.NVarChar, email)
      .query('SELECT id FROM Users WHERE email = @email');
    if (exists.recordset.length)
      return res.status(409).json({ success: false, message: 'Email already registered.' });

    // Verify the immeuble belongs to this syndic
    const syndicRes = await pool.request()
      .input('userId', sql.Int, req.user.id)
      .query('SELECT id FROM Syndics WHERE userId = @userId');
    const syndicId = syndicRes.recordset[0]?.id;

    const immRes = await pool.request()
      .input('immeubleId', sql.Int, immeubleId)
      .input('syndicId',   sql.Int, syndicId)
      .query('SELECT id, nom FROM Immeubles WHERE id = @immeubleId AND syndicId = @syndicId');
    if (!immRes.recordset[0])
      return res.status(403).json({ success: false, message: 'Immeuble not found or not owned by you.' });

    const immeubleNom = immRes.recordset[0].nom;

    // Use provided password or generate one
    const plainPassword = password || generatePassword();
    const hashedPassword = await bcrypt.hash(plainPassword, 12);

    // Create user
    const userRes = await pool.request()
      .input('email',    sql.NVarChar, email)
      .input('password', sql.NVarChar, hashedPassword)
      .input('role',     sql.NVarChar, type)
      .query(`INSERT INTO Users (email, password, role) OUTPUT INSERTED.id VALUES (@email, @password, @role)`);
    const userId = userRes.recordset[0].id;

    // Create habitant profile
    const habitantRes = await pool.request()
      .input('userId',         sql.Int,      userId)
      .input('type',           sql.NVarChar, type)
      .input('nom',            sql.NVarChar, nom)
      .input('prenom',         sql.NVarChar, prenom)
      .input('telephone',      sql.NVarChar, telephone      || null)
      .input('immeubleId',     sql.Int,      immeubleId)
      .input('appartement',    sql.NVarChar, appartement    || null)
      .input('proprietaireId', sql.Int,      proprietaireId || null)
      .input('dateEntree',     sql.Date,     dateEntree     || null)
      .input('dateSortie',     sql.Date,     dateSortie     || null)
      .query(`
        INSERT INTO Habitants (userId, type, nom, prenom, telephone, immeubleId, appartement, proprietaireId, dateEntree, dateSortie)
        OUTPUT INSERTED.*
        VALUES (@userId, @type, @nom, @prenom, @telephone, @immeubleId, @appartement, @proprietaireId, @dateEntree, @dateSortie)
      `);
    const habitant = habitantRes.recordset[0];

    // Optional email dispatch
    if (sendEmail) {
      try {
        await emailService.sendCredentials({ to: email, nom, prenom, email, password: plainPassword, immeubleNom });
      } catch (emailErr) {
        console.error('[Email] Failed to send credentials:', emailErr.message);
      }
    }

    res.status(201).json({
      success: true,
      message: `Habitant created.${sendEmail ? ' Credentials sent by email.' : ''}`,
      data: habitant,
      // Return plain password in response so syndic can share it manually if needed
      credentials: { email, password: plainPassword },
    });
  } catch (err) { next(err); }
};

// ── GET /api/habitants  (syndic lists all habitants in their buildings) ──
const getAllHabitants = async (req, res, next) => {
  try {
    const pool = await getPool();
    const { immeubleId, type } = req.query;

    const syndicRes = await pool.request()
      .input('userId', sql.Int, req.user.id)
      .query('SELECT id FROM Syndics WHERE userId = @userId');
    const syndicId = syndicRes.recordset[0]?.id;

    const conditions = ['i.syndicId = @syndicId'];
    const request    = pool.request().input('syndicId', sql.Int, syndicId);

    if (immeubleId) { conditions.push('h.immeubleId = @immeubleId'); request.input('immeubleId', sql.Int, immeubleId); }
    if (type)       { conditions.push('h.type = @type');             request.input('type', sql.NVarChar, type); }

    const result = await request.query(`
      SELECT h.*, u.email, u.isActive,
             i.nom  AS immeubleNom,
             p.nom  AS proprietaireNom, p.prenom AS proprietairePrenom
      FROM   Habitants h
      INNER JOIN Users      u ON h.userId        = u.id
      LEFT  JOIN Immeubles  i ON h.immeubleId    = i.id
      LEFT  JOIN Habitants  p ON h.proprietaireId = p.id
      WHERE ${conditions.join(' AND ')}
      ORDER BY h.type, h.nom, h.prenom
    `);

    res.json({ success: true, data: result.recordset });
  } catch (err) { next(err); }
};

// ── GET /api/habitants/:id ───────────────────────────────────────────
const getHabitantById = async (req, res, next) => {
  try {
    const pool   = await getPool();
    const result = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query(`
        SELECT h.*, u.email, u.isActive,
               i.nom  AS immeubleNom,
               p.nom  AS proprietaireNom, p.prenom AS proprietairePrenom
        FROM   Habitants h
        INNER JOIN Users     u ON h.userId        = u.id
        LEFT  JOIN Immeubles i ON h.immeubleId    = i.id
        LEFT  JOIN Habitants p ON h.proprietaireId = p.id
        WHERE h.id = @id
      `);
    if (!result.recordset[0])
      return res.status(404).json({ success: false, message: 'Habitant not found.' });
    res.json({ success: true, data: result.recordset[0] });
  } catch (err) { next(err); }
};

// ── PUT /api/habitants/:id  (syndic updates a resident) ──────────────
const updateHabitant = async (req, res, next) => {
  try {
    const { nom, prenom, telephone, appartement, immeubleId, proprietaireId, dateEntree, dateSortie } = req.body;
    const pool = await getPool();

    await pool.request()
      .input('id',             sql.Int,      req.params.id)
      .input('nom',            sql.NVarChar, nom)
      .input('prenom',         sql.NVarChar, prenom)
      .input('telephone',      sql.NVarChar, telephone      || null)
      .input('appartement',    sql.NVarChar, appartement    || null)
      .input('immeubleId',     sql.Int,      immeubleId     || null)
      .input('proprietaireId', sql.Int,      proprietaireId || null)
      .input('dateEntree',     sql.Date,     dateEntree     || null)
      .input('dateSortie',     sql.Date,     dateSortie     || null)
      .query(`
        UPDATE Habitants
        SET nom=@nom, prenom=@prenom, telephone=@telephone, appartement=@appartement,
            immeubleId=@immeubleId, proprietaireId=@proprietaireId,
            dateEntree=@dateEntree, dateSortie=@dateSortie, updatedAt=GETDATE()
        WHERE id = @id
      `);

    res.json({ success: true, message: 'Habitant updated.' });
  } catch (err) { next(err); }
};

// ── DELETE /api/habitants/:id ────────────────────────────────────────
const deleteHabitant = async (req, res, next) => {
  try {
    const pool = await getPool();
    await pool.request()
      .input('id', sql.Int, req.params.id)
      .query('DELETE FROM Habitants WHERE id = @id');
    res.json({ success: true, message: 'Habitant deleted.' });
  } catch (err) { next(err); }
};

// ── GET /api/habitants/profile/me  (habitant views own profile) ──────
const getMyProfile = async (req, res, next) => {
  try {
    const pool   = await getPool();
    const result = await pool.request()
      .input('userId', sql.Int, req.user.id)
      .query(`
        SELECT h.*, u.email,
               i.nom     AS immeubleNom,    i.adresse AS immeubleAdresse,
               p.nom     AS proprietaireNom, p.prenom AS proprietairePrenom,
               p.telephone AS proprietaireTel
        FROM   Habitants h
        INNER JOIN Users     u ON h.userId        = u.id
        LEFT  JOIN Immeubles i ON h.immeubleId    = i.id
        LEFT  JOIN Habitants p ON h.proprietaireId = p.id
        WHERE h.userId = @userId
      `);
    res.json({ success: true, data: result.recordset[0] });
  } catch (err) { next(err); }
};

// ── PUT /api/habitants/:id/reset-password  (syndic resets password) ──
const resetPassword = async (req, res, next) => {
  try {
    const pool = await getPool();
    const { newPassword, sendEmail: doSendEmail } = req.body;

    // Get the user linked to this habitant
    const hRes = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query(`SELECT h.*, u.email FROM Habitants h INNER JOIN Users u ON h.userId=u.id WHERE h.id=@id`);

    if (!hRes.recordset[0])
      return res.status(404).json({ success: false, message: 'Habitant not found.' });

    const habitant      = hRes.recordset[0];
    const plainPassword = newPassword || (() => {
      const chars = 'ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789@#$!';
      let pw = '';
      for (let i = 0; i < 10; i++) pw += chars[Math.floor(Math.random() * chars.length)];
      return pw;
    })();

    const hashed = await bcrypt.hash(plainPassword, 12);
    await pool.request()
      .input('userId',   sql.Int,      habitant.userId)
      .input('password', sql.NVarChar, hashed)
      .query('UPDATE Users SET password=@password, updatedAt=GETDATE() WHERE id=@userId');

    if (doSendEmail) {
      try {
        // Get immeuble name
        const immRes = await pool.request()
          .input('id', sql.Int, habitant.immeubleId)
          .query('SELECT nom FROM Immeubles WHERE id=@id');
        await emailService.sendCredentials({
          to: habitant.email, nom: habitant.nom, prenom: habitant.prenom,
          email: habitant.email, password: plainPassword,
          immeubleNom: immRes.recordset[0]?.nom || '',
        });
      } catch (e) { console.error('[Email] reset-password:', e.message); }
    }

    res.json({ success: true, message: 'Password reset.', credentials: { email: habitant.email, password: plainPassword } });
  } catch (err) { next(err); }
};

module.exports = { createHabitant, getAllHabitants, getHabitantById, updateHabitant, deleteHabitant, getMyProfile, resetPassword };
