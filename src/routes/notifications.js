const express = require('express');
const router = express.Router();
const { authenticate, authorize } = require('../middleware/auth');
const {
  getNotifications, markAsRead, markAllAsRead, sendNotification,
} = require('../controllers/notificationsController');

router.get('/',              authenticate, getNotifications);
router.put('/read-all',      authenticate, markAllAsRead);
router.put('/:id/read',      authenticate, markAsRead);
router.post('/send',         authenticate, authorize('syndic', 'admin'), sendNotification);

module.exports = router;
