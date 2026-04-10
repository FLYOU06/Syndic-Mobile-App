const express = require('express');
const router = express.Router();
const { authenticate, authorize } = require('../middleware/auth');
const {
  getAllProprietaires, getProprietaireById,
  updateProprietaire, getMyProfile,
} = require('../controllers/proprietairesController');

router.get('/profile/me', authenticate, authorize('proprietaire'), getMyProfile);
router.get('/',    authenticate, authorize('syndic', 'admin'), getAllProprietaires);
router.get('/:id', authenticate, getProprietaireById);
router.put('/:id', authenticate, authorize('syndic', 'admin'), updateProprietaire);

module.exports = router;
