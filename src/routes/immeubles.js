const express = require('express');
const router = express.Router();
const { authenticate, authorize } = require('../middleware/auth');
const {
  getAllImmeubles, getImmeubleById, createImmeuble,
  updateImmeuble, deleteImmeuble,
} = require('../controllers/immeublesController');

router.get('/',       authenticate, authorize('syndic'), getAllImmeubles);
router.get('/:id',    authenticate, authorize('syndic'), getImmeubleById);
router.post('/',      authenticate, authorize('syndic'), createImmeuble);
router.put('/:id',    authenticate, authorize('syndic'), updateImmeuble);
router.delete('/:id', authenticate, authorize('syndic'), deleteImmeuble);

module.exports = router;
