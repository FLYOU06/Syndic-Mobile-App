const { getPool, sql } = require('../config/database');
const notificationService = require('../services/notificationService');

// GET /api/notifications
const getNotifications = async (req, res, next) => {
  try {
    const pool = await getPool();
    const { isRead, page = 1, limit = 30 } = req.query;
    const offset = (page - 1) * limit;

    let where = 'WHERE userId = @userId';
    if (isRead !== undefined) where += ` AND isRead = ${isRead === 'true' ? 1 : 0}`;

    const result = await pool.request()
      .input('userId', sql.Int, req.user.id)
      .query(`SELECT * FROM Notifications ${where} ORDER BY createdAt DESC OFFSET ${offset} ROWS FETCH NEXT ${limit} ROWS ONLY`);

    const unread = await pool.request()
      .input('userId', sql.Int, req.user.id)
      .query('SELECT COUNT(*) AS count FROM Notifications WHERE userId=@userId AND isRead=0');

    res.json({ success: true, data: result.recordset, unreadCount: unread.recordset[0].count });
  } catch (err) { next(err); }
};

// PUT /api/notifications/:id/read
const markAsRead = async (req, res, next) => {
  try {
    const pool = await getPool();
    await pool.request()
      .input('id',     sql.Int, req.params.id)
      .input('userId', sql.Int, req.user.id)
      .query('UPDATE Notifications SET isRead=1 WHERE id=@id AND userId=@userId');
    res.json({ success: true, message: 'Marked as read.' });
  } catch (err) { next(err); }
};

// PUT /api/notifications/read-all
const markAllAsRead = async (req, res, next) => {
  try {
    const pool = await getPool();
    await pool.request()
      .input('userId', sql.Int, req.user.id)
      .query('UPDATE Notifications SET isRead=1 WHERE userId=@userId');
    res.json({ success: true, message: 'All notifications marked as read.' });
  } catch (err) { next(err); }
};

// POST /api/notifications/send  (syndic broadcasts to a building)
const sendNotification = async (req, res, next) => {
  try {
    const { immeubleId, titre, message, type } = req.body;
    if (!immeubleId || !titre || !message)
      return res.status(400).json({ success: false, message: 'immeubleId, titre and message are required.' });

    const pool = await getPool();
    const habitants = await pool.request()
      .input('immeubleId', sql.Int, immeubleId)
      .query('SELECT userId FROM Habitants WHERE immeubleId = @immeubleId');

    let sent = 0;
    for (const h of habitants.recordset) {
      await notificationService.create(h.userId, titre, message, type || 'info');
      sent++;
    }

    res.json({ success: true, message: `Notification sent to ${sent} habitant(s).` });
  } catch (err) { next(err); }
};

module.exports = { getNotifications, markAsRead, markAllAsRead, sendNotification };
