const express = require('express');
const router = express.Router();
const { authenticate, authorize } = require('../middleware/auth');
const {
  getAllCharges, getChargeById, createCharge,
  updateCharge, deleteCharge, getImpayesDashboard,
} = require('../controllers/chargesController');

router.get('/impayes/dashboard', authenticate, authorize('syndic', 'admin'), getImpayesDashboard);
router.get('/',    authenticate, getAllCharges);
router.get('/:id', authenticate, getChargeById);
router.post('/',   authenticate, authorize('syndic', 'admin'), createCharge);
router.put('/:id', authenticate, authorize('syndic', 'admin'), updateCharge);
router.delete('/:id', authenticate, authorize('syndic', 'admin'), deleteCharge);

module.exports = router;
