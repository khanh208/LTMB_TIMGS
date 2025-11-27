const pool = require('../config/db');

const findUserByEmail = async (email) => {
  const result = await pool.query(
    'SELECT * FROM mentor_match.Users WHERE email = $1',
    [email]
  );
  return result.rows[0];
};

const createUser = async (email, hashedPassword, fullName, role) => {
  const result = await pool.query(
    'INSERT INTO mentor_match.Users (email, password_hash, full_name, role) VALUES ($1, $2, $3, $4) RETURNING *',
    [email, hashedPassword, fullName, role]
  );
  return result.rows[0];
};

const findUserById = async (userId) => {
  const result = await pool.query(
    'SELECT * FROM mentor_match.Users WHERE user_id = $1',
    [userId]
  );
  return result.rows[0];
};

const updateUser = async (userId, { fullName, phoneNumber, avatarUrl }) => {
  const result = await pool.query(
    `UPDATE mentor_match.Users 
     SET 
        full_name = COALESCE($1, full_name),
        phone_number = COALESCE($2, phone_number),
        avatar_url = COALESCE($3, avatar_url) 
     WHERE user_id = $4 
     RETURNING *`,
    [fullName, phoneNumber, avatarUrl, userId]
  );
  return result.rows[0];
};

const updatePassword = async (userId, hashedPassword) => {
  await pool.query(
    'UPDATE mentor_match.Users SET password_hash = $1 WHERE user_id = $2',
    [hashedPassword, userId]
  );
};

const getSavedTutors = async (userId) => {
  const result = await pool.query(
    `SELECT T.user_id, T.full_name, T.avatar_url, P.bio, P.price_per_hour, P.average_rating
     FROM mentor_match.SavedTutors S
     JOIN mentor_match.Users T ON S.tutor_user_id = T.user_id
     JOIN mentor_match.TutorProfiles P ON S.tutor_user_id = P.user_id
     WHERE S.student_user_id = $1`,
    [userId]
  );
  return result.rows;
};

const saveTutor = async (userId, tutorId) => {
  await pool.query(
    'INSERT INTO mentor_match.SavedTutors (student_user_id, tutor_user_id) VALUES ($1, $2) ON CONFLICT DO NOTHING',
    [userId, tutorId]
  );
};

const unsaveTutor = async (userId, tutorId) => {
  await pool.query(
    'DELETE FROM mentor_match.SavedTutors WHERE student_user_id = $1 AND tutor_user_id = $2',
    [userId, tutorId]
  );
};

module.exports = {
  findUserByEmail,
  createUser,
  findUserById, 
  updateUser,
  updatePassword,
  getSavedTutors,
  saveTutor,
  unsaveTutor,
};