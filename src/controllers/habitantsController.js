const { getPool, sql } = require('../config/database');

// GET /api/habitants  (syndic only)
const getAllHabitants = async (req, res, next) => {
  try {
    const pool = await getPool();
    const { type, immeubleId, proprietaireId } = req.query;

    const syndicRes = await pool.request()
      .input('userId', sql.Int, req.user.id)
      .query('SELECT id FROM Syndics WHERE userId = @userId');
    const syndicId = syndicRes.recordset[0]?.id;

    const conditions = ['i.syndicId = @syndicId'];
    const request = pool.request().input('syndicId', sql.Int, syndicId);

    if (type)           { conditions.push('h.type = @type');                       request.input('type',           sql.NVarChar, type); }
    if (immeubleId)     { conditions.push('h.immeubleId = @immeubleId');           request.input('immeubleId',     sql.Int, immeubleId); }
    if (proprietaireId) { conditions.push('h.proprietaireId = @proprietaireId');   request.input('proprietaireId', sql.Int, proprietaireId); }

    const result = await request.query(`
      SELECT h.*, u.email, u.isActive,
             i.nom  AS immeubleNom,
             p.nom  AS proprietaireNom, p.prenom AS proprietairePrenom
      FROM Habitants h
      INNER JOIN Users      u ON h.userId         = u.id
      LEFT JOIN  Immeubles  i ON h.immeubleId      = i.id
      LEFT JOIN  Habitants  p ON h.proprietaireId  = p.id
      WHERE ${conditions.join(' AND ')}
      ORDER BY h.type, h.nom, h.prenom
    `);

    res.json({ success: true, data: result.recordset });
  } catch (err) { next(err); }
};

// GET /api/habitants/:id
const getHabitantById = async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query(`
        SELECT h.*, u.email, u.isActive,
               i.nom  AS immeubleNom,
               p.nom  AS proprietaireNom, p.prenom AS proprietairePrenom
        FROM Habitants h
        INNER JOIN Users     u ON h.userId         = u.id
        LEFT JOIN  Immeubles i ON h.immeubleId      = i.id
        LEFT JOIN  Habitants p ON h.proprietaireId  = p.id
        WHERE h.id = @id
      `);

    if (!result.recordset[0])
      return res.status(404).json({ success: false, message: 'Habitant not found.' });

    res.json({ success: true, data: result.recordset[0] });
  } catch (err) { next(err); }
};

// PUT /api/habitants/:id  (syndic only)
const updateHabitant = async (req, res, next) => {
  try {
    const { nom, prenom, telephone, appartement, immeubleId, proprietaireId, dateEntree, dateSortie } = req.body;
    const pool = await getPool();

    await pool.request()
      .input('id',             sql.Int,      req.params.id)
      .input('nom',            sql.NVarChar, nom)
      .input('prenom',         sql.NVarChar, prenom)
      .input('telephone',      sql.NVarChar, telephone      || null)
      .input('appartement',    sql.NVarChar, appartement    || null)
      .input('immeubleId',     sql.Int,      immeubleId     || null)
      .input('proprietaireId', sql.Int,      proprietaireId || null)
      .input('dateEntree',     sql.Date,     dateEntree     || null)
      .input('dateSortie',     sql.Date,     dateSortie     || null)
      .query(`
        UPDATE Habitants
        SET nom=@nom, prenom=@prenom, telephone=@telephone, appartement=@appartement,
            immeubleId=@immeubleId, proprietaireId=@proprietaireId,
            dateEntree=@dateEntree, dateSortie=@dateSortie, updatedAt=GETDATE()
        WHERE id=@id
      `);

    res.json({ success: true, message: 'Habitant updated.' });
  } catch (err) { next(err); }
};

// DELETE /api/habitants/:id  (syndic only)
const deleteHabitant = async (req, res, next) => {
  try {
    const pool = await getPool();
    await pool.request()
      .input('id', sql.Int, req.params.id)
      .query('DELETE FROM Habitants WHERE id = @id');
    res.json({ success: true, message: 'Habitant deleted.' });
  } catch (err) { next(err); }
};

// GET /api/habitants/profile/me  (proprietaire or locataire self)
const getMyProfile = async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('userId', sql.Int, req.user.id)
      .query(`
        SELECT h.*, u.email,
               i.nom     AS immeubleNom,    i.adresse AS immeubleAdresse,
               p.nom     AS proprietaireNom, p.prenom AS proprietairePrenom,
               p.telephone AS proprietaireTel
        FROM Habitants h
        INNER JOIN Users     u ON h.userId         = u.id
        LEFT JOIN  Immeubles i ON h.immeubleId      = i.id
        LEFT JOIN  Habitants p ON h.proprietaireId  = p.id
        WHERE h.userId = @userId
      `);

    res.json({ success: true, data: result.recordset[0] });
  } catch (err) { next(err); }
};

module.exports = { getAllHabitants, getHabitantById, updateHabitant, deleteHabitant, getMyProfile };