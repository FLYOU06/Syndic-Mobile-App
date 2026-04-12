const express = require('express');
const router  = express.Router();
const { authenticate, authorize } = require('../middleware/auth');
const { getAllCharges, getChargeById, createCharge, updateCharge, deleteCharge, getImpayesDashboard } = require('../controllers/chargesController');

router.get('/impayes/dashboard', authenticate, authorize('syndic'), getImpayesDashboard);
router.get('/',    authenticate, getAllCharges);
router.get('/:id', authenticate, getChargeById);
router.post('/',   authenticate, authorize('syndic'), createCharge);
router.put('/:id', authenticate, authorize('syndic'), updateCharge);
router.delete('/:id', authenticate, authorize('syndic'), deleteCharge);

module.exports = router;