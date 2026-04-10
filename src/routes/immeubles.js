const express = require('express');
const router = express.Router();
const { authenticate, authorize } = require('../middleware/auth');
const {
  getAllImmeubles, getImmeubleById, createImmeuble,
  updateImmeuble, deleteImmeuble,
} = require('../controllers/immeublesController');

router.get('/',       authenticate, authorize('syndic', 'admin'), getAllImmeubles);
router.get('/:id',    authenticate, authorize('syndic', 'admin'), getImmeubleById);
router.post('/',      authenticate, authorize('syndic', 'admin'), createImmeuble);
router.put('/:id',    authenticate, authorize('syndic', 'admin'), updateImmeuble);
router.delete('/:id', authenticate, authorize('syndic', 'admin'), deleteImmeuble);

module.exports = router;
