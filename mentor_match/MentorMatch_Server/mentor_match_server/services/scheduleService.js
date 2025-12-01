// services/scheduleService.js
const scheduleModel = require('../models/scheduleModel');
const tutorModel = require('../models/tutorModel');
const walletModel = require('../models/walletModel');

const getSchedule = async (userId, role) => {
  return await scheduleModel.findScheduleByUserId(userId, role);
};

const createProposal = async (tutorId, { studentId, subjectId, slots }) => {
  const tutorProfile = await tutorModel.findProfileById(tutorId);
  if (!tutorProfile || !tutorProfile.price_per_hour) {
    throw new Error('Gia sư chưa cập nhật giá tiền.');
  }
  const pricePerHour = parseFloat(tutorProfile.price_per_hour);

  const groupId = `GROUP_${Date.now()}_${tutorId}`;

  const schedules = await scheduleModel.createBulkSchedules(tutorId, studentId, subjectId, slots, pricePerHour, groupId);

  const totalAmount = schedules.reduce((sum, item) => sum + parseFloat(item.price), 0);

  return {
    groupId,
    totalAmount,
    schedules
  };
};

const getProposalDetails = async (groupId) => {
  const schedules = await scheduleModel.findByGroupId(groupId);
  if (!schedules || schedules.length === 0) {
    throw new Error('Không tìm thấy lịch học.');
  }
  const totalAmount = schedules.reduce((sum, item) => sum + parseFloat(item.price), 0);
  return { schedules, totalAmount };
};

const payAndConfirm = async (studentId, groupId) => {
  const schedules = await scheduleModel.findByGroupId(groupId);
  if (schedules.length === 0) throw new Error('Yêu cầu không tồn tại.');
  
  if (schedules[0].status === 'confirmed') throw new Error('Lịch học này đã được thanh toán.');

  const totalAmount = schedules.reduce((sum, item) => sum + parseFloat(item.price), 0);
  const tutorId = schedules[0].tutor_user_id;

  const studentWallet = await walletModel.findWalletByUserId(studentId);
  if (parseFloat(studentWallet.balance) < totalAmount) {
    throw new Error('Số dư ví không đủ để thanh toán.');
  }

  const client = await require('../config/db').connect();
  try {
    await client.query('BEGIN');

    await walletModel.updateBalance(studentWallet.wallet_id, parseFloat(studentWallet.balance) - totalAmount);
    await walletModel.createTransaction(studentWallet.wallet_id, -totalAmount, 'payment', `Thanh toán lịch học nhóm ${groupId}`);

    const tutorWallet = await walletModel.findWalletByUserId(tutorId);
    await walletModel.updateBalance(tutorWallet.wallet_id, parseFloat(tutorWallet.balance) + totalAmount);
    await walletModel.createTransaction(tutorWallet.wallet_id, totalAmount, 'earning', `Nhận thanh toán lịch học nhóm ${groupId}`);

    await scheduleModel.confirmGroupSchedule(groupId);

    await client.query('COMMIT');
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }

  return { message: 'Thanh toán thành công!', totalAmount };
};

const updateScheduleStatus = async (scheduleId, userId, status) => {
  const schedule = await scheduleModel.findById(scheduleId);
  if (!schedule) throw new Error('Lịch không tồn tại');
  
  if (schedule.tutor_user_id !== userId && schedule.student_user_id !== userId) {
    throw new Error('Không có quyền.');
  }

  return await scheduleModel.updateStatus(scheduleId, status);
};

const rejectProposal = async (userId, groupId) => {
  const schedules = await scheduleModel.findByGroupId(groupId);
  if (!schedules || schedules.length === 0) {
    throw new Error('Yêu cầu không tồn tại.');
  }

  const firstItem = schedules[0];
  if (firstItem.student_user_id !== userId && firstItem.tutor_user_id !== userId) {
    throw new Error('Bạn không có quyền từ chối yêu cầu này.');
  }

  if (firstItem.status === 'confirmed') {
    throw new Error('Lịch học đã được thanh toán, không thể từ chối theo cách này.');
  }

  return await scheduleModel.cancelGroupSchedule(groupId);
};

module.exports = {
  getSchedule,
  createProposal,
  getProposalDetails,
  payAndConfirm,
  updateScheduleStatus,
  rejectProposal,
};