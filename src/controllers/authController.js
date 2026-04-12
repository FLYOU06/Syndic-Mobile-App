const bcrypt = require('bcryptjs');
const jwt    = require('jsonwebtoken');
const { getPool, sql } = require('../config/database');

// ── Helper: fetch profile from Habitants ───────────────────────────
const getProfile = async (pool, role, userId) => {
  if (role === 'syndic') {
    const r = await pool.request()
      .input('userId', sql.Int, userId)
      .query('SELECT * FROM Syndics WHERE userId = @userId');
    return r.recordset[0] || null;
  }
  if (role === 'proprietaire' || role === 'locataire') {
    const r = await pool.request()
      .input('userId', sql.Int, userId)
      .query(`
        SELECT h.*, i.nom AS immeubleNom,
               p.nom AS proprietaireNom, p.prenom AS proprietairePrenom
        FROM Habitants h
        LEFT JOIN Immeubles h2 ON h.immeubleId  = h2.id
        LEFT JOIN Immeubles i  ON h.immeubleId  = i.id
        LEFT JOIN Habitants p  ON h.proprietaireId = p.id
        WHERE h.userId = @userId
      `);
    return r.recordset[0] || null;
  }
  return null;
};

// POST /api/auth/login
const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    if (!email || !password)
      return res.status(400).json({ success: false, message: 'Email and password are required.' });

    const pool = await getPool();
    const result = await pool.request()
      .input('email', sql.NVarChar, email)
      .query('SELECT * FROM Users WHERE email = @email AND isActive = 1');

    const user = result.recordset[0];
    if (!user)
      return res.status(401).json({ success: false, message: 'Invalid email or password.' });

    const isMatch = await require('bcryptjs').compare(password, user.password);
    if (!isMatch)
      return res.status(401).json({ success: false, message: 'Invalid email or password.' });

    const profile = await getProfile(pool, user.role, user.id);

    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    res.json({
      success: true,
      message: 'Login successful',
      token,
      user: { id: user.id, email: user.email, role: user.role, profile },
    });
  } catch (err) { next(err); }
};

// POST /api/auth/register  (syndic only)
const register = async (req, res, next) => {
  try {
    const {
      email, password, role,
      nom, prenom, telephone,
      immeubleId, appartement,
      proprietaireId,  // locataire only — ID of their owner in Habitants
      dateEntree, dateSortie,
    } = req.body;

    if (!email || !password || !role || !nom || !prenom)
      return res.status(400).json({ success: false, message: 'Missing required fields.' });

    const validRoles = ['syndic', 'proprietaire', 'locataire'];
    if (!validRoles.includes(role))
      return res.status(400).json({ success: false, message: `Invalid role. Must be: ${validRoles.join(', ')}` });

    const pool = await getPool();

    const exists = await pool.request()
      .input('email', sql.NVarChar, email)
      .query('SELECT id FROM Users WHERE email = @email');
    if (exists.recordset.length > 0)
      return res.status(409).json({ success: false, message: 'Email already registered.' });

    const hashed = await bcrypt.hash(password, 12);
    const userResult = await pool.request()
      .input('email',    sql.NVarChar, email)
      .input('password', sql.NVarChar, hashed)
      .input('role',     sql.NVarChar, role)
      .query(`INSERT INTO Users (email, password, role) OUTPUT INSERTED.id VALUES (@email, @password, @role)`);
    const userId = userResult.recordset[0].id;

    if (role === 'syndic') {
      await pool.request()
        .input('userId',    sql.Int,      userId)
        .input('nom',       sql.NVarChar, nom)
        .input('prenom',    sql.NVarChar, prenom)
        .input('telephone', sql.NVarChar, telephone || null)
        .query(`INSERT INTO Syndics (userId,nom,prenom,telephone) VALUES (@userId,@nom,@prenom,@telephone)`);
    }

    if (role === 'proprietaire' || role === 'locataire') {
      await pool.request()
        .input('userId',         sql.Int,      userId)
        .input('type',           sql.NVarChar, role)
        .input('nom',            sql.NVarChar, nom)
        .input('prenom',         sql.NVarChar, prenom)
        .input('telephone',      sql.NVarChar, telephone      || null)
        .input('immeubleId',     sql.Int,      immeubleId     || null)
        .input('appartement',    sql.NVarChar, appartement    || null)
        .input('proprietaireId', sql.Int,      proprietaireId || null)
        .input('dateEntree',     sql.Date,     dateEntree     || null)
        .input('dateSortie',     sql.Date,     dateSortie     || null)
        .query(`
          INSERT INTO Habitants
            (userId,type,nom,prenom,telephone,immeubleId,appartement,proprietaireId,dateEntree,dateSortie)
          VALUES
            (@userId,@type,@nom,@prenom,@telephone,@immeubleId,@appartement,@proprietaireId,@dateEntree,@dateSortie)
        `);
    }

    res.status(201).json({ success: true, message: `${role} registered successfully.`, userId });
  } catch (err) { next(err); }
};

// GET /api/auth/me
const getMe = async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('id', sql.Int, req.user.id)
      .query('SELECT id, email, role, isActive, createdAt FROM Users WHERE id = @id');
    const user = result.recordset[0];
    const profile = await getProfile(pool, user.role, user.id);
    res.json({ success: true, user: { ...user, profile } });
  } catch (err) { next(err); }
};

// PUT /api/auth/change-password
const changePassword = async (req, res, next) => {
  try {
    const { currentPassword, newPassword } = req.body;
    const pool = await getPool();
    const result = await pool.request()
      .input('id', sql.Int, req.user.id)
      .query('SELECT password FROM Users WHERE id = @id');
    const isMatch = await bcrypt.compare(currentPassword, result.recordset[0].password);
    if (!isMatch)
      return res.status(400).json({ success: false, message: 'Current password is incorrect.' });
    const hashed = await bcrypt.hash(newPassword, 12);
    await pool.request()
      .input('id',       sql.Int,      req.user.id)
      .input('password', sql.NVarChar, hashed)
      .query('UPDATE Users SET password=@password, updatedAt=GETDATE() WHERE id=@id');
    res.json({ success: true, message: 'Password updated successfully.' });
  } catch (err) { next(err); }
};

module.exports = { login, register, getMe, changePassword };