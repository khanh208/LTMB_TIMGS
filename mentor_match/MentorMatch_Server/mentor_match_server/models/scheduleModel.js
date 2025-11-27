// models/scheduleModel.js
const pool = require('../config/db');
const { USER_ROLES } = require('../config/constants');

const findScheduleByUserId = async (userId, role) => {
  let query = `
    SELECT S.*, 
           T.full_name as tutor_name, 
           St.full_name as student_name,
           Sub.name as subject_name
    FROM mentor_match.Schedule S
    JOIN mentor_match.Users T ON S.tutor_user_id = T.user_id
    JOIN mentor_match.Users St ON S.student_user_id = St.user_id
    JOIN mentor_match.Subjects Sub ON S.subject_id = Sub.subject_id
  `;

  if (role === USER_ROLES.TUTOR) {
    query += ' WHERE S.tutor_user_id = $1';
  } else if (role === USER_ROLES.STUDENT) {
    query += ' WHERE S.student_user_id = $1';
  }
  query += ' ORDER BY S.start_time DESC';

  const result = await pool.query(query, [userId]);
  return result.rows;
};

const create = async (tutorId, studentId, subjectId, startTime, endTime) => {
  const result = await pool.query(
    `INSERT INTO mentor_match.Schedule (tutor_user_id, student_user_id, subject_id, start_time, end_time)
     VALUES ($1, $2, $3, $4, $5) RETURNING *`,
    [tutorId, studentId, subjectId, startTime, endTime]
  );
  return result.rows[0];
};

const findById = async (scheduleId) => {
  const result = await pool.query(
    'SELECT * FROM mentor_match.Schedule WHERE schedule_id = $1',
    [scheduleId]
  );
  return result.rows[0];
};

const update = async (scheduleId, { status, startTime, endTime }) => {
  const result = await pool.query(
    `UPDATE mentor_match.Schedule
     SET status = $1, start_time = $2, end_time = $3
     WHERE schedule_id = $4 RETURNING *`,
    [status, startTime, endTime, scheduleId]
  );
  return result.rows[0];
};

module.exports = {
  findScheduleByUserId,
  create,
  findById,
  update,
};