const express = require('express');
const router  = express.Router();
const { authenticate, authorize } = require('../middleware/auth');
const { getRapportFinancier, getRapportImpayes, getRapportHistory } = require('../controllers/rapportsController');

router.get('/financier', authenticate, authorize('syndic'), getRapportFinancier);
router.get('/impayes',   authenticate, authorize('syndic'), getRapportImpayes);
router.get('/history',   authenticate, authorize('syndic'), getRapportHistory);

module.exports = router;