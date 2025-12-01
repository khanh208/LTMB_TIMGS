const tutorService = require('../services/tutorService');

const searchTutors = async (req, res) => {
  try {
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
    const updates = req.body; 
    const updatedProfile = await tutorService.updateMyProfile(userId, updates);
    res.status(200).json({
      message: 'Cập nhật hồ sơ thành công!',
      profile: updatedProfile
    });
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

const getMyTutorProfile = async (req, res) => {
  try {
    const userId = req.user.userId; 
    const profile = await tutorService.getMyFullProfile(userId);
    res.status(200).json(profile);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  searchTutors,
  getTutorProfile,
  updateMyTutorProfile,
  getDashboard,
  getEarnings,
  requestWithdrawal,
  getMyTutorProfile,
};