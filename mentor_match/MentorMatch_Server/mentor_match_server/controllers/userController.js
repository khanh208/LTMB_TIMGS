const userService = require('../services/userService');

const getMyProfile = async (req, res) => {
  try {
    const userId = req.user.userId;
    const userProfile = await userService.getProfile(userId);
    res.status(200).json(userProfile);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const updateMyProfile = async (req, res) => {
  try {
    const userId = req.user.userId;
    const updates = req.body; 
    const updatedUser = await userService.updateProfile(userId, updates);
    res.status(200).json(updatedUser);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const changePassword = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { currentPassword, newPassword } = req.body;
    await userService.changePassword(userId, currentPassword, newPassword);
    res.status(200).json({ message: 'Đổi mật khẩu thành công.' });
  } catch (error) {
    res.status(401).json({ message: error.message });
  }
};

const getWallet = async (req, res) => {
  try {
    const userId = req.user.userId;
    const wallet = await userService.getWallet(userId);
    res.status(200).json(wallet);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const requestDeposit = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { amount, method } = req.body;
    const depositInfo = await userService.requestDeposit(userId, amount, method);
    res.status(201).json(depositInfo);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const getSavedTutors = async (req, res) => {
  try {
    const userId = req.user.userId;
    const tutors = await userService.getSavedTutors(userId);
    res.status(200).json(tutors);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const saveTutor = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { tutorId } = req.body;
    await userService.saveTutor(userId, tutorId);
    res.status(201).json({ message: 'Đã lưu gia sư.' });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const unsaveTutor = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { tutorId } = req.params;
    await userService.unsaveTutor(userId, tutorId);
    res.status(200).json({ message: 'Đã bỏ lưu gia sư.' });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const uploadAvatar = async (req, res) => {
  try {
    const { avatarBase64 } = req.body; 

    if (!avatarBase64) {
      return res.status(400).json({ message: 'Thiếu dữ liệu ảnh (Base64).' });
    }

    const userId = req.user.userId;

    await userService.updateProfile(userId, { avatarUrl: avatarBase64 });

    res.status(200).json({ 
      message: 'Cập nhật ảnh thành công!', 
      avatarUrl: avatarBase64 
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  getMyProfile,
  updateMyProfile,
  changePassword,
  getWallet,
  requestDeposit,
  getSavedTutors,
  saveTutor,
  unsaveTutor,
  uploadAvatar
};
