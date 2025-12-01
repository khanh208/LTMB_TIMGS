const pool = require('../config/db');

const create = async (studentId, tutorId, scheduleId, rating, comment) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const reviewQuery = `
      INSERT INTO mentor_match.Reviews (student_user_id, tutor_user_id, schedule_id, rating, comment)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *
    `;
    const reviewRes = await client.query(reviewQuery, [studentId, tutorId, scheduleId, rating, comment]);

    const avgQuery = `
      UPDATE mentor_match.TutorProfiles
      SET average_rating = (
        SELECT AVG(rating) FROM mentor_match.Reviews WHERE tutor_user_id = $1
      )
      WHERE user_id = $1
    `;
    await client.query(avgQuery, [tutorId]);

    await client.query('COMMIT');
    return reviewRes.rows[0];
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }
};

const canReview = async (studentId, tutorId, scheduleId) => {
    const result = await pool.query(
        `SELECT 1 FROM mentor_match.Schedule
         WHERE student_user_id = $1 
           AND tutor_user_id = $2 
           AND schedule_id = $3
           AND status = 'completed'`,
        [studentId, tutorId, scheduleId]
    );
    return result.rows.length > 0;
};

module.exports = {
  create,
  canReview,
};