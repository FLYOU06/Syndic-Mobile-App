const { getPool, sql } = require('../config/database');

/**
 * Create a single in-app notification.
 */
const create = async (userId, titre, message, type = 'info') => {
  try {
    const pool = await getPool();
    await pool.request()
      .input('userId',  sql.Int,      userId)
      .input('titre',   sql.NVarChar, titre)
      .input('message', sql.NVarChar, message)
      .input('type',    sql.NVarChar, type)
      .query(`INSERT INTO Notifications (userId, titre, message, type) VALUES (@userId, @titre, @message, @type)`);
  } catch (err) {
    console.error('[NotificationService] create error:', err.message);
  }
};

/**
 * Broadcast the same notification to multiple userIds.
 */
const broadcast = async (userIds, titre, message, type = 'info') => {
  for (const userId of userIds) {
    await create(userId, titre, message, type);
  }
};

module.exports = { create, broadcast };
