const userModel = require('../models/userModel');
const walletModel = require('../models/walletModel');
const bcrypt = require('bcrypt');

const getProfile = async (userId) => {
  const user = await userModel.findUserById(userId);
  if (!user) {
    throw new Error('Không tìm thấy người dùng.');
  }
  user.password_hash = undefined; 
  return user;
};

const updateProfile = async (userId, updates) => {
  const { fullName, phoneNumber, avatarUrl } = updates;
  const updatedUser = await userModel.updateUser(userId, { fullName, phoneNumber, avatarUrl });
  updatedUser.password_hash = undefined;
  return updatedUser;
};

const changePassword = async (userId, currentPassword, newPassword) => {
  const user = await userModel.findUserById(userId);
  if (!user) {
    throw new Error('Người dùng không tồn tại.');
  }

  const isValidPassword = await bcrypt.compare(currentPassword, user.password_hash);
  if (!isValidPassword) {
    throw new Error('Mật khẩu hiện tại không chính xác.');
  }

  const salt = await bcrypt.genSalt(10);
  const hashedNewPassword = await bcrypt.hash(newPassword, salt);

  await userModel.updatePassword(userId, hashedNewPassword);
  return true;
};

const getWallet = async (userId) => {
  const wallet = await walletModel.findWalletByUserId(userId);
  if (!wallet) {
    throw new Error('Không tìm thấy ví.');
  }
  return wallet;
};

const requestDeposit = async (userId, amount, method) => {
  if (amount <= 0 || !method) {
    throw new Error('Thông tin nạp tiền không hợp lệ.');
  }
  
  const depositInfo = {
    userId,
    amount,
    method,
    status: 'pending',
    message: 'Đang chờ xác nhận thanh toán Momo...',
  };
  return depositInfo;
};

const getSavedTutors = async (userId) => {
  return await userModel.getSavedTutors(userId);
};

const saveTutor = async (userId, tutorId) => {
  if (!tutorId) {
    throw new Error('Thiếu ID Gia sư.');
  }
  return await userModel.saveTutor(userId, tutorId);
};

const unsaveTutor = async (userId, tutorId) => {
  return await userModel.unsaveTutor(userId, tutorId);
};

module.exports = {
  getProfile,
  updateProfile,
  changePassword,
  getWallet,
  requestDeposit,
  getSavedTutors,
  saveTutor,
  unsaveTutor,
};