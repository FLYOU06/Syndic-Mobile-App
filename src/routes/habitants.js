const express = require('express');
const router  = express.Router();
const { authenticate, authorize } = require('../middleware/auth');
const {
  getAllHabitants, getHabitantById,
  updateHabitant, deleteHabitant, getMyProfile,
} = require('../controllers/habitantsController');

router.get('/profile/me', authenticate, authorize('proprietaire', 'locataire'), getMyProfile);
router.get('/',           authenticate, authorize('syndic'),                    getAllHabitants);
router.get('/:id',        authenticate,                                         getHabitantById);
router.put('/:id',        authenticate, authorize('syndic'),                    updateHabitant);
router.delete('/:id',     authenticate, authorize('syndic'),                    deleteHabitant);

module.exports = router;
