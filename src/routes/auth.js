const express = require('express');
const router  = express.Router();
const { authenticate, authorize } = require('../middleware/auth');
const { login, register, getMe, changePassword } = require('../controllers/authController');

router.post('/login',           login);
router.post('/register',        authenticate, authorize('syndic'), register);
router.get('/me',               authenticate, getMe);
router.put('/change-password',  authenticate, changePassword);

module.exports = router;
