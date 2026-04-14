const express = require('express');
const router  = express.Router();
const { authenticate } = require('../middleware/auth');
const { login, getMe, changePassword } = require('../controllers/authController');

// No public /register — only syndic can create accounts via /api/habitants
router.post('/login',           login);
router.get('/me',               authenticate, getMe);
router.put('/change-password',  authenticate, changePassword);

module.exports = router;
