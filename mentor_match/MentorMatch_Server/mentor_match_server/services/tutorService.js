const tutorModel = require('../models/tutorModel');
const walletModel = require('../models/walletModel');
const chatModel = require('../models/chatModel');
const { REQUEST_STATUS } = require('../config/constants');

const searchTutors = async (filters) => {
  return await tutorModel.search(filters);
};

const createRequest = async (studentId, tutorId, message) => {
  if (!tutorId) {
    throw new Error('Thiếu ID Gia sư.');
  }
  return await tutorModel.createRequest(studentId, tutorId, message);
};

const getProfile = async (tutorId) => {
  const profile = await tutorModel.findProfileById(tutorId);
  if (!profile) {
    throw new Error('Không tìm thấy hồ sơ gia sư.');
  }
  profile.subjects = await tutorModel.findSubjectsByTutorId(tutorId);
  profile.reviews = await tutorModel.findReviewsByTutorId(tutorId);
  profile.certificates = await tutorModel.getCertificates(tutorId); 
  
  return profile;
};

const getMyFullProfile = async (userId) => {
  return await getProfile(userId);
};

const updateMyProfile = async (userId, updates) => {
  return await tutorModel.updateFullProfileTx(userId, {
    bio: updates.bio,
    price_per_hour: updates.price_per_hour,
    subjectIds: updates.subjects,
    certificates: updates.certificates
  });
};


const getDashboard = async (userId) => {
  return {
    monthlyRevenue: 5200000,
    newStudents: 3,
    completedSessions: 22,
    pendingRequests: 2,
  };
};

const getEarnings = async (userId) => {
  const wallet = await walletModel.findWalletByUserId(userId);
  const transactions = await walletModel.findTransactionsByWalletId(wallet.wallet_id);
  
  return {
    balance: wallet.balance,
    transactions: transactions,
  };
};

const requestWithdrawal = async (userId, amount, bankInfo) => {
  const wallet = await walletModel.findWalletByUserId(userId);
  if (amount > wallet.balance) {
    throw new Error('Số dư không đủ.');
  }
  if (!bankInfo) {
    throw new Error('Thiếu thông tin ngân hàng.');
  }

  const withdrawal = await walletModel.createTransaction(wallet.wallet_id, -amount, 'withdrawal', `Rút tiền về ${bankInfo.bankName}`);
  
  await walletModel.updateBalance(wallet.wallet_id, wallet.balance - amount);
  
  return withdrawal;
};

const getRequests = async (userId, status) => {
  return await tutorModel.findRequests(userId, status);
};

const respondToRequest = async (userId, requestId, status) => {
  if (status !== REQUEST_STATUS.ACCEPTED && status !== REQUEST_STATUS.DECLINED) {
    throw new Error('Trạng thái không hợp lệ.');
  }

  const request = await tutorModel.updateRequestStatus(requestId, status, userId);

  if (status === REQUEST_STATUS.ACCEPTED) {
    await chatModel.createRoom(request.student_user_id, request.tutor_user_id);
  }
  
  return request;
};

module.exports = {
  searchTutors,
  createRequest,
  getProfile,
  updateMyProfile,
  getDashboard,
  getEarnings,
  requestWithdrawal,
  getRequests,
  respondToRequest,
  getMyFullProfile,
};