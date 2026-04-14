const express = require('express');
const router  = express.Router();
const { authenticate, authorize } = require('../middleware/auth');
const {
  createHabitant, getAllHabitants, getHabitantById,
  updateHabitant, deleteHabitant, getMyProfile, resetPassword,
} = require('../controllers/habitantsController');

router.get('/profile/me',           authenticate, authorize('proprietaire','locataire'), getMyProfile);
router.get('/',                     authenticate, authorize('syndic'),                   getAllHabitants);
router.get('/:id',                  authenticate,                                        getHabitantById);
router.post('/',                    authenticate, authorize('syndic'),                   createHabitant);
router.put('/:id',                  authenticate, authorize('syndic'),                   updateHabitant);
router.delete('/:id',               authenticate, authorize('syndic'),                   deleteHabitant);
router.put('/:id/reset-password',   authenticate, authorize('syndic'),                   resetPassword);

module.exports = router;
