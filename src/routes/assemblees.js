const express = require('express');
const router  = express.Router();
const { authenticate, authorize } = require('../middleware/auth');
const { getAllAssemblees, getAssembleeById, createAssemblee, updateAssemblee, deleteAssemblee } = require('../controllers/assembleesController');

router.get('/',    authenticate,                      getAllAssemblees);
router.get('/:id', authenticate,                      getAssembleeById);
router.post('/',   authenticate, authorize('syndic'), createAssemblee);
router.put('/:id', authenticate, authorize('syndic'), updateAssemblee);
router.delete('/:id', authenticate, authorize('syndic'), deleteAssemblee);

module.exports = router;
