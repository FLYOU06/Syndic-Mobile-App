const express = require('express');
const router  = express.Router();
const { authenticate, authorize } = require('../middleware/auth');
const { getAllPaiements, createPaiement, getSuiviPaiements } = require('../controllers/paiementsController');

router.get('/',                    authenticate, getAllPaiements);
router.post('/',                   authenticate, authorize('syndic'), createPaiement);
router.get('/suivi/:habitantId',   authenticate, getSuiviPaiements);

module.exports = router;