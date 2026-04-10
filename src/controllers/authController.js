const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { getPool, sql } = require('../config/database');

// POST /api/auth/login
const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Email and password are required.' });
    }

    const pool = await getPool();
    const result = await pool.request()
      .input('email', sql.NVarChar, email)
      .query('SELECT * FROM Users WHERE email = @email AND isActive = 1');

    const user = result.recordset[0];
    if (!user) {
      return res.status(401).json({ success: false, message: 'Invalid email or password.' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Invalid email or password.' });
    }

    // Get profile info based on role
    let profile = null;
    if (user.role === 'syndic') {
      const syndicResult = await pool.request()
        .input('userId', sql.Int, user.id)
        .query('SELECT * FROM Syndics WHERE userId = @userId');
      profile = syndicResult.recordset[0] || null;
    } else if (user.role === 'proprietaire') {
      const propResult = await pool.request()
        .input('userId', sql.Int, user.id)
        .query(`SELECT p.*, i.nom AS immeubleNom 
                FROM Proprietaires p
                LEFT JOIN Immeubles i ON p.immeubleId = i.id
                WHERE p.userId = @userId`);
      profile = propResult.recordset[0] || null;
    }

    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    res.json({
      success: true,
      message: 'Login successful',
      token,
      user: {
        id: user.id,
        email: user.email,
        role: user.role,
        profile,
      },
    });
  } catch (err) {
    next(err);
  }
};

// POST /api/auth/register  (admin only)
const register = async (req, res, next) => {
  try {
    const { email, password, role, nom, prenom, telephone, immeubleId, appartement } = req.body;

    if (!email || !password || !role || !nom || !prenom) {
      return res.status(400).json({ success: false, message: 'Missing required fields.' });
    }

    const pool = await getPool();

    // Check email uniqueness
    const exists = await pool.request()
      .input('email', sql.NVarChar, email)
      .query('SELECT id FROM Users WHERE email = @email');

    if (exists.recordset.length > 0) {
      return res.status(409).json({ success: false, message: 'Email already registered.' });
    }

    const hashedPassword = await bcrypt.hash(password, 12);

    // Create user
    const userResult = await pool.request()
      .input('email', sql.NVarChar, email)
      .input('password', sql.NVarChar, hashedPassword)
      .input('role', sql.NVarChar, role)
      .query(`INSERT INTO Users (email, password, role) 
              OUTPUT INSERTED.id 
              VALUES (@email, @password, @role)`);

    const userId = userResult.recordset[0].id;

    // Create profile based on role
    if (role === 'syndic') {
      await pool.request()
        .input('userId', sql.Int, userId)
        .input('nom', sql.NVarChar, nom)
        .input('prenom', sql.NVarChar, prenom)
        .input('telephone', sql.NVarChar, telephone || null)
        .query(`INSERT INTO Syndics (userId, nom, prenom, telephone) 
                VALUES (@userId, @nom, @prenom, @telephone)`);
    } else if (role === 'proprietaire') {
      await pool.request()
        .input('userId', sql.Int, userId)
        .input('nom', sql.NVarChar, nom)
        .input('prenom', sql.NVarChar, prenom)
        .input('telephone', sql.NVarChar, telephone || null)
        .input('immeubleId', sql.Int, immeubleId || null)
        .input('appartement', sql.NVarChar, appartement || null)
        .query(`INSERT INTO Proprietaires (userId, nom, prenom, telephone, immeubleId, appartement) 
                VALUES (@userId, @nom, @prenom, @telephone, @immeubleId, @appartement)`);
    }

    res.status(201).json({ success: true, message: `${role} registered successfully.`, userId });
  } catch (err) {
    next(err);
  }
};

// GET /api/auth/me
const getMe = async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('id', sql.Int, req.user.id)
      .query('SELECT id, email, role, isActive, createdAt FROM Users WHERE id = @id');

    res.json({ success: true, user: result.recordset[0] });
  } catch (err) {
    next(err);
  }
};

// POST /api/auth/change-password
const changePassword = async (req, res, next) => {
  try {
    const { currentPassword, newPassword } = req.body;
    const pool = await getPool();

    const result = await pool.request()
      .input('id', sql.Int, req.user.id)
      .query('SELECT password FROM Users WHERE id = @id');

    const user = result.recordset[0];
    const isMatch = await bcrypt.compare(currentPassword, user.password);
    if (!isMatch) {
      return res.status(400).json({ success: false, message: 'Current password is incorrect.' });
    }

    const hashed = await bcrypt.hash(newPassword, 12);
    await pool.request()
      .input('id', sql.Int, req.user.id)
      .input('password', sql.NVarChar, hashed)
      .query('UPDATE Users SET password = @password, updatedAt = GETDATE() WHERE id = @id');

    res.json({ success: true, message: 'Password updated successfully.' });
  } catch (err) {
    next(err);
  }
};

module.exports = { login, register, getMe, changePassword };
