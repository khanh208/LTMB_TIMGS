// controllers/tutorController.js
const tutorService = require('../services/tutorService');

const createRequest = async (req, res) => {
  try {
    const studentId = req.user.userId; // Lấy từ middleware 'protect'
    const { tutorId } = req.params;   // Lấy từ URL
    const { message } = req.body;     // Lấy từ body
    
    const newRequest = await tutorService.createRequest(studentId, tutorId, message);
    res.status(201).json(newRequest);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const searchTutors = async (req, res) => {
  try {
    // Lấy các query params từ URL (VD: /api/tutors?category=tin_hoc&rating=4)
    const filters = req.query;
    const tutors = await tutorService.searchTutors(filters);
    res.status(200).json(tutors);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getTutorProfile = async (req, res) => {
  try {
    const { tutorId } = req.params;
    const profile = await tutorService.getProfile(tutorId);
    res.status(200).json(profile);
  } catch (error) {
    res.status(404).json({ message: error.message });
  }
};

const updateMyTutorProfile = async (req, res) => {
  try {
    const userId = req.user.userId;
    const updates = req.body; // { bio, price_per_hour, subjects }
    const updatedProfile = await tutorService.updateMyProfile(userId, updates);
    res.status(200).json(updatedProfile);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const getDashboard = async (req, res) => {
  try {
    const userId = req.user.userId;
    const dashboardData = await tutorService.getDashboard(userId);
    res.status(200).json(dashboardData);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getEarnings = async (req, res) => {
  try {
    const userId = req.user.userId;
    const earningsData = await tutorService.getEarnings(userId);
    res.status(200).json(earningsData);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const requestWithdrawal = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { amount, bankInfo } = req.body;
    const withdrawal = await tutorService.requestWithdrawal(userId, amount, bankInfo);
    res.status(201).json(withdrawal);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const getRequests = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { status } = req.query; // (VD: /requests?status=pending)
    const requests = await tutorService.getRequests(userId, status);
    res.status(200).json(requests);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const respondToRequest = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { requestId } = req.params;
    const { status } = req.body; // 'accepted' hoặc 'declined'
    await tutorService.respondToRequest(userId, requestId, status);
    res.status(200).json({ message: `Đã ${status} yêu cầu.` });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

module.exports = {
  searchTutors,
  getTutorProfile,
  updateMyTutorProfile,
  getDashboard,
  getEarnings,
  requestWithdrawal,
};