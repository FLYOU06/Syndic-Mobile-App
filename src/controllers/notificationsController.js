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
// POST /api/notifications/send
// Flutter sends: { titre, message, type, assemblee_id } OR { titre, message, type, immeubleId }
// If assemblee_id is provided, the immeubleId is resolved from AssembleesGenerales.
const sendNotification = async (req, res, next) => {
  try {
    const { titre, message, type, assemblee_id, immeubleId: bodyImmeubleId } = req.body;

    if (!titre || !message)
      return res.status(400).json({ success: false, message: 'titre and message are required.' });

    const pool = await getPool();
    let resolvedImmeubleId = bodyImmeubleId ?? null;

    // Resolve immeubleId from assemblee_id (Flutter convocation + PV flow)
    if (assemblee_id && !resolvedImmeubleId) {
      const agRes = await pool.request()
        .input('id', sql.Int, assemblee_id)
        .query('SELECT immeubleId FROM AssembleesGenerales WHERE id = @id');
      resolvedImmeubleId = agRes.recordset[0]?.immeubleId ?? null;
    }

    // Fallback: broadcast to all habitants of the syndic's buildings
    let habitants;
    if (resolvedImmeubleId) {
      habitants = await pool.request()
        .input('immeubleId', sql.Int, resolvedImmeubleId)
        .query('SELECT userId FROM Habitants WHERE immeubleId = @immeubleId');
    } else {
      // No target specified — notify all habitants managed by this syndic
      const syndicRes = await pool.request()
        .input('userId', sql.Int, req.user.id)
        .query('SELECT id FROM Syndics WHERE userId = @userId');
      const syndicId = syndicRes.recordset[0]?.id;
      if (!syndicId)
        return res.status(403).json({ success: false, message: 'Syndic profile not found.' });

      habitants = await pool.request()
        .input('syndicId', sql.Int, syndicId)
        .query(`SELECT h.userId FROM Habitants h
                INNER JOIN Immeubles i ON h.immeubleId = i.id
                WHERE i.syndicId = @syndicId`);
    }

    let sent = 0;
    // Sanitize type — DB only allows known values; map Flutter custom types to 'info'
    const allowedTypes = ['info', 'alerte', 'paiement', 'assemblee', 'charge'];
    const safeType = allowedTypes.includes(type) ? type : 'info';

    for (const h of habitants.recordset) {
      await notificationService.create(h.userId, titre, message, safeType);
      sent++;
    }

    res.json({ success: true, message: `Notification envoyée à ${sent} habitant(s).`, sent });
  } catch (err) { next(err); }
};

module.exports = { getNotifications, markAsRead, markAllAsRead, sendNotification };
