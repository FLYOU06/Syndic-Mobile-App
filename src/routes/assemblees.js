const express = require('express');
const router = express.Router();
const { authenticate, authorize } = require('../middleware/auth');
const {
  getAllAssemblees, getAssembleeById, createAssemblee,
  updateAssemblee, deleteAssemblee,
} = require('../controllers/assembleesController');

router.get('/',    authenticate, getAllAssemblees);
router.get('/:id', authenticate, getAssembleeById);
router.post('/',   authenticate, authorize('syndic', 'admin'), createAssemblee);
router.put('/:id', authenticate, authorize('syndic', 'admin'), updateAssemblee);
router.delete('/:id', authenticate, authorize('syndic', 'admin'), deleteAssemblee);

module.exports = router;
