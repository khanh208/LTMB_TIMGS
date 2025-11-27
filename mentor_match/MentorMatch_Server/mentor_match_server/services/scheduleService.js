// services/scheduleService.js
const scheduleModel = require('../models/scheduleModel');
const { SCHEDULE_STATUS } = require('../config/constants');

const getSchedule = async (userId, role) => {
  return await scheduleModel.findScheduleByUserId(userId, role);
};

const createSchedule = async (tutorId, studentId, subjectId, startTime, endTime) => {
  if (!studentId || !subjectId || !startTime || !endTime) {
    throw new Error('Thiếu thông tin lịch hẹn.');
  }
  return await scheduleModel.create(tutorId, studentId, subjectId, startTime, endTime);
};

const updateSchedule = async (scheduleId, userId, updates) => {
  const schedule = await scheduleModel.findById(scheduleId);
  if (!schedule) {
    throw new Error('Không tìm thấy lịch hẹn.');
  }

  if (schedule.tutor_user_id !== userId && schedule.student_user_id !== userId) {
    throw new Error('Bạn không có quyền cập nhật lịch hẹn này.');
  }
  
  const currentStatus = schedule.status;
  const currentStartTime = schedule.start_time;
  const currentEndTime = schedule.end_time;
  
  const newStatus = updates.status || currentStatus;
  const newStartTime = updates.startTime || currentStartTime;
  const newEndTime = updates.endTime || currentEndTime;

  return await scheduleModel.update(scheduleId, {
    status: newStatus,
    startTime: newStartTime,
    endTime: newEndTime,
  });
};

module.exports = {
  getSchedule,
  createSchedule,
  updateSchedule,
};