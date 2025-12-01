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

  const params = [userId];

  if (role === USER_ROLES.TUTOR) {
    query += ' WHERE S.tutor_user_id = $1';
  } else if (role === USER_ROLES.STUDENT) {
    query += ' WHERE S.student_user_id = $1';
  }
  
  // --- CẬP NHẬT Ở ĐÂY: Thêm 'pending_payment' vào danh sách ---
  query += " AND S.status IN ('confirmed', 'completed', 'cancelled', 'pending_payment') ORDER BY S.start_time DESC";

  const result = await pool.query(query, params);
  return result.rows;
};

const createBulkSchedules = async (tutorId, studentId, subjectId, slots, pricePerHour, groupId) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    
    const results = [];
    for (const slot of slots) {
      const start = new Date(slot.startTime);
      const end = new Date(slot.endTime);
      const durationHours = (end - start) / (1000 * 60 * 60);
      const cost = durationHours * pricePerHour;

      const query = `
        INSERT INTO mentor_match.Schedule 
        (tutor_user_id, student_user_id, subject_id, start_time, end_time, status, booking_group_id, price)
        VALUES ($1, $2, $3, $4, $5, 'pending_payment', $6, $7)
        RETURNING *
      `;
      const res = await client.query(query, [tutorId, studentId, subjectId, slot.startTime, slot.endTime, groupId, cost]);
      results.push(res.rows[0]);
    }

    await client.query('COMMIT');
    return results;
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }
};

const findByGroupId = async (groupId) => {
  const result = await pool.query(
    `SELECT S.*, Sub.name as subject_name, T.full_name as tutor_name
     FROM mentor_match.Schedule S
     JOIN mentor_match.Subjects Sub ON S.subject_id = Sub.subject_id
     JOIN mentor_match.Users T ON S.tutor_user_id = T.user_id
     WHERE S.booking_group_id = $1`,
    [groupId]
  );
  return result.rows;
};

const confirmGroupSchedule = async (groupId) => {
  const result = await pool.query(
    `UPDATE mentor_match.Schedule 
     SET status = 'confirmed' 
     WHERE booking_group_id = $1 
     RETURNING *`,
    [groupId]
  );
  return result.rows;
};

const updateStatus = async (scheduleId, status) => {
  const result = await pool.query(
    `UPDATE mentor_match.Schedule SET status = $1 WHERE schedule_id = $2 RETURNING *`,
    [status, scheduleId]
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

const cancelGroupSchedule = async (groupId) => {
  const result = await pool.query(
    `UPDATE mentor_match.Schedule 
     SET status = 'cancelled' 
     WHERE booking_group_id = $1 
     RETURNING *`,
    [groupId]
  );
  return result.rows;
};

module.exports = {
  findScheduleByUserId,
  createBulkSchedules,
  findByGroupId,
  confirmGroupSchedule,
  updateStatus,
  findById,
  cancelGroupSchedule,
};