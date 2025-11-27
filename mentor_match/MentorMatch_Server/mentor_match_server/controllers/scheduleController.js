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

const createSchedule = async (req, res) => {
  try {
    const tutorId = req.user.userId;
    const { studentId, subjectId, startTime, endTime } = req.body;
    const newSchedule = await scheduleService.createSchedule(tutorId, studentId, subjectId, startTime, endTime);
    res.status(201).json(newSchedule);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const updateSchedule = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { scheduleId } = req.params;
    const { status, startTime, endTime } = req.body;
    const updatedSchedule = await scheduleService.updateSchedule(scheduleId, userId, { status, startTime, endTime });
    res.status(200).json(updatedSchedule);
  } catch (error) {
    res.status(403).json({ message: error.message });
  }
};

module.exports = {
  getMySchedule,
  createSchedule,
  updateSchedule,
};