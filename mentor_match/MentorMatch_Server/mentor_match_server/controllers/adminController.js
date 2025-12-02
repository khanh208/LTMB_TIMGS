const pool = require('../config/db');       
const tutorModel = require('../models/tutorModel');
const userModel = require('../models/userModel');

const getPendingTutors = async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT U.user_id, U.full_name, U.email, P.bio, P.price_per_hour, P.is_verified
      FROM mentor_match.Users U
      JOIN mentor_match.TutorProfiles P ON U.user_id = P.user_id
      WHERE U.role = 'tutor' AND P.is_verified = FALSE
      ORDER BY U.created_at DESC
    `);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const verifyTutor = async (req, res) => {
  try {
    const { tutorId } = req.params;
    const { isVerified } = req.body; 

    await pool.query(
      'UPDATE mentor_match.TutorProfiles SET is_verified = $1 WHERE user_id = $2',
      [isVerified, tutorId]
    );

    res.status(200).json({ message: 'Cập nhật trạng thái thành công.' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getTutorDetailForAdmin = async (req, res) => {
  try {
    const { tutorId } = req.params;
    const profile = await tutorModel.findProfileById(tutorId);
    const certificates = await tutorModel.getCertificates(tutorId);
    
    res.status(200).json({ ...profile, certificates });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  getPendingTutors,
  verifyTutor,
  getTutorDetailForAdmin
};