const express = require('express');
const router  = express.Router();
const { authenticate, authorize } = require('../middleware/auth');
const {
  createCharge, getAllCharges, getChargeById,
  updateCharge, deleteCharge,
  recordPaiement, notifyUnpaid, getImpayesDashboard,
} = require('../controllers/chargesController');

router.get('/impayes/dashboard',  authenticate, authorize('syndic'), getImpayesDashboard);
router.get('/',                   authenticate,                      getAllCharges);
router.get('/:id',                authenticate,                      getChargeById);
router.post('/',                  authenticate, authorize('syndic'), createCharge);
router.put('/:id',                authenticate, authorize('syndic'), updateCharge);
router.delete('/:id',             authenticate, authorize('syndic'), deleteCharge);
router.post('/:id/paiement',      authenticate, authorize('syndic'), recordPaiement);
router.post('/:id/notify-unpaid', authenticate, authorize('syndic'), notifyUnpaid);

module.exports = router;
