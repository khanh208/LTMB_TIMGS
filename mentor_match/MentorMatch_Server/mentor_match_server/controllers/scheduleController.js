// controllers/scheduleController.js
const scheduleService = require('../services/scheduleService');

const getMySchedule = async (req, res) => {
  try {
    const userId = req.user.userId;
    const role = req.user.role;
    const schedule = await scheduleService.getSchedule(userId, role);
    res.status(200).json(schedule);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const createProposal = async (req, res) => {
  try {
    const tutorId = req.user.userId;
    const { studentId, subjectId, slots } = req.body;
    const result = await scheduleService.createProposal(tutorId, { studentId, subjectId, slots });
    res.status(201).json(result);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const getProposal = async (req, res) => {
  try {
    const { groupId } = req.params;
    const result = await scheduleService.getProposalDetails(groupId);
    res.status(200).json(result);
  } catch (error) {
    res.status(404).json({ message: error.message });
  }
};

const confirmPayment = async (req, res) => {
  try {
    const studentId = req.user.userId;
    const { groupId } = req.body;
    const result = await scheduleService.payAndConfirm(studentId, groupId);
    res.status(200).json(result);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const updateStatus = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { scheduleId } = req.params;
    const { status } = req.body;
    const result = await scheduleService.updateScheduleStatus(scheduleId, userId, status);
    res.status(200).json(result);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const rejectProposal = async (req, res) => {
  try {
    const userId = req.user.userId; // Người thực hiện từ chối
    const { groupId } = req.body;
    
    await scheduleService.rejectProposal(userId, groupId);
    
    res.status(200).json({ message: 'Đã từ chối yêu cầu lịch học.' });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

module.exports = {
  getMySchedule,
  createProposal,
  getProposal,
  confirmPayment,
  updateStatus,
  rejectProposal, 
};