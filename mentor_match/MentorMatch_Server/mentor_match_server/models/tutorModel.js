const pool = require('../config/db');

const createProfile = async (userId) => {
  await pool.query(
    'INSERT INTO mentor_match.TutorProfiles (user_id, bio, price_per_hour, is_verified) VALUES ($1, null, null, false)',
    [userId]
  );
};

const createRequest = async (studentId, tutorId, message) => {
  const result = await pool.query(
    `INSERT INTO mentor_match.ConnectionRequests (student_user_id, tutor_user_id, message, status)
     VALUES ($1, $2, $3, 'pending')
     RETURNING *`,
    [studentId, tutorId, message]
  );
  return result.rows[0];
};

const search = async (filters) => {
  const { search, category, minRating, maxPrice, page = 1, limit = 20 } = filters;

  // 1. Query cơ bản (Lấy thông tin từ các bảng cũ)
  let query = `
    SELECT U.user_id, U.full_name, U.avatar_url, 
           P.bio, P.price_per_hour, P.average_rating, P.is_verified,
           (SELECT COUNT(*) FROM mentor_match.Reviews R WHERE R.tutor_user_id = U.user_id) as reviews_count
    FROM mentor_match.Users U
    JOIN mentor_match.TutorProfiles P ON U.user_id = P.user_id
    WHERE U.role = 'tutor'
  `;
  
  const queryParams = [];
  let paramCount = 1; // Biến đếm thứ tự $1, $2...

  // 2. Tìm kiếm theo Tên hoặc Bio (Dùng ILIKE để không phân biệt hoa thường)
  if (search) {
    query += ` AND (U.full_name ILIKE $${paramCount} OR P.bio ILIKE $${paramCount})`;
    queryParams.push(`%${search}%`); // Thêm % để tìm kiếm tương đối
    paramCount++;
  }

  // 3. Lọc theo Category (Logic cũ của bạn, rất ổn)
  if (category) {
    query += ` AND P.user_id IN (
      SELECT ts.tutor_user_id FROM mentor_match.TutorSubjects ts
      JOIN mentor_match.Subjects s ON ts.subject_id = s.subject_id
      WHERE s.category = $${paramCount}
    )`;
    queryParams.push(category);
    paramCount++;
  }

  // 4. Lọc theo Đánh giá (Rating)
  if (minRating) {
    query += ` AND P.average_rating >= $${paramCount}`;
    queryParams.push(minRating);
    paramCount++;
  }

  // 5. Lọc theo Giá (Price)
  if (maxPrice) {
    query += ` AND P.price_per_hour <= $${paramCount}`;
    queryParams.push(maxPrice);
    paramCount++;
  }

  // 6. Sắp xếp (Mặc định: Người có rating cao lên đầu, sau đó đến người mới)
  query += ` ORDER BY P.average_rating DESC, U.created_at DESC`;

  // 7. Phân trang (Pagination) - QUAN TRỌNG
  const offset = (page - 1) * limit;
  query += ` LIMIT $${paramCount} OFFSET $${paramCount + 1}`;
  queryParams.push(limit, offset);

  // Thực thi
  const result = await pool.query(query, queryParams);
  
  // (Optional) Lấy thêm danh sách môn học cho từng gia sư để hiển thị đẹp hơn
  // Đoạn này tùy bạn, nếu không cần hiển thị môn học ngay ở list thì bỏ qua.
  const tutors = result.rows;
  for (let tutor of tutors) {
    const subjectsRes = await pool.query(
      `SELECT s.name FROM mentor_match.Subjects s
       JOIN mentor_match.TutorSubjects ts ON s.subject_id = ts.subject_id
       WHERE ts.tutor_user_id = $1`,
      [tutor.user_id]
    );
    tutor.subjects = subjectsRes.rows.map(r => r.name); // Trả về mảng tên môn: ["Toán", "Lý"]
  }

  return tutors;
};

const findProfileById = async (tutorId) => {
  const result = await pool.query(
    `SELECT U.user_id, U.full_name, U.email, U.phone_number, U.avatar_url, 
            P.bio, P.price_per_hour, P.average_rating, P.is_verified
     FROM mentor_match.Users U
     JOIN mentor_match.TutorProfiles P ON U.user_id = P.user_id
     WHERE U.user_id = $1 AND U.role = 'tutor'`,
    [tutorId]
  );
  return result.rows[0];
};

const findSubjectsByTutorId = async (tutorId) => {
  const result = await pool.query(
    `SELECT S.subject_id, S.name, S.category
     FROM mentor_match.Subjects S
     JOIN mentor_match.TutorSubjects TS ON S.subject_id = TS.subject_id
     WHERE TS.tutor_user_id = $1`,
    [tutorId]
  );
  return result.rows;
};  

const findReviewsByTutorId = async (tutorId) => {
  const result = await pool.query(
    `SELECT R.review_id, R.rating, R.comment, R.created_at, U.full_name as student_name
     FROM mentor_match.Reviews R
     JOIN mentor_match.Users U ON R.student_user_id = U.user_id
     WHERE R.tutor_user_id = $1
     ORDER BY R.created_at DESC`,
    [tutorId]
  );
  return result.rows;
};

const updateProfile = async (userId, { bio, price_per_hour }) => {
  const result = await pool.query(
    `UPDATE mentor_match.TutorProfiles
     SET bio = $1, price_per_hour = $2
     WHERE user_id = $3 RETURNING *`,
    [bio, price_per_hour, userId]
  );
  return result.rows[0];
};

const updateSubjects = async (tutorId, subjectIds) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await client.query('DELETE FROM mentor_match.TutorSubjects WHERE tutor_user_id = $1', [tutorId]);
    const insertQuery = 'INSERT INTO mentor_match.TutorSubjects (tutor_user_id, subject_id) VALUES ($1, $2)';
    for (const subjectId of subjectIds) {
      await client.query(insertQuery, [tutorId, subjectId]);
    }
    await client.query('COMMIT');
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }
};

const findRequests = async (tutorId, status) => {
  let query = `
    SELECT R.request_id, R.message, R.status, R.created_at, U.full_name as student_name, U.avatar_url
    FROM mentor_match.ConnectionRequests R
    JOIN mentor_match.Users U ON R.student_user_id = U.user_id
    WHERE R.tutor_user_id = $1
  `;
  const params = [tutorId];
  
  if (status) {
    params.push(status);
    query += ` AND R.status = $2`;
  } else {
    query += ` AND R.status != 'pending'`;
  }
  
  query += ' ORDER BY R.created_at DESC';
  
  const result = await pool.query(query, params);
  return result.rows;
};

const updateRequestStatus = async (requestId, status, tutorId) => {
  const result = await pool.query(
    `UPDATE mentor_match.ConnectionRequests
     SET status = $1
     WHERE request_id = $2 AND tutor_user_id = $3
     RETURNING *`,
    [status, requestId, tutorId]
  );
  return result.rows[0];
};

const updateFullProfileTx = async (userId, { bio, price_per_hour, subjectIds, certificates }) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const updateProfileQuery = `
      UPDATE mentor_match.TutorProfiles
      SET bio = $1, price_per_hour = $2
      WHERE user_id = $3
      RETURNING *
    `;
    const profileRes = await client.query(updateProfileQuery, [bio, price_per_hour, userId]);

    if (subjectIds && Array.isArray(subjectIds)) {
      await client.query('DELETE FROM mentor_match.TutorSubjects WHERE tutor_user_id = $1', [userId]);
      
      if (subjectIds.length > 0) {
        const subjectValues = subjectIds.map((_, i) => `($1, $${i + 2})`).join(',');
        const subjectQuery = `INSERT INTO mentor_match.TutorSubjects (tutor_user_id, subject_id) VALUES ${subjectValues}`;
        await client.query(subjectQuery, [userId, ...subjectIds]);
      }
    }

    if (certificates && Array.isArray(certificates)) {
      await client.query('DELETE FROM mentor_match.TutorCertificates WHERE tutor_user_id = $1', [userId]);

      if (certificates.length > 0) {
        for (const cert of certificates) {
          await client.query(
            'INSERT INTO mentor_match.TutorCertificates (tutor_user_id, title, image_url) VALUES ($1, $2, $3)',
            [userId, cert.title, cert.imageBase64]
          );
        }
      }
    }

    await client.query('COMMIT');
    return profileRes.rows[0];

  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }
};

const getCertificates = async (tutorId) => {
  const result = await pool.query(
    'SELECT * FROM mentor_match.TutorCertificates WHERE tutor_user_id = $1',
    [tutorId]
  );
  return result.rows;
};

module.exports = {
  createProfile,
  createRequest,  
  search,
  findProfileById,
  findSubjectsByTutorId,
  findReviewsByTutorId,
  updateProfile,
  updateSubjects,
  findRequests,
  updateRequestStatus,
  updateFullProfileTx,
  getCertificates
};