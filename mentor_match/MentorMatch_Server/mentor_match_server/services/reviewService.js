const reviewModel = require('../models/reviewModel');

const postReview = async (studentId, { tutorId, scheduleId, rating, comment }) => {
  if (!tutorId || !scheduleId || !rating) {
    throw new Error('Thiếu thông tin tutorId, scheduleId, hoặc rating.');
  }
  
  const canReview = await reviewModel.canReview(studentId, tutorId, scheduleId);
  if (!canReview) {
    throw new Error('Bạn không thể đánh giá buổi học này (có thể do chưa hoàn thành hoặc đã đánh giá).');
  }
  
  return await reviewModel.create(studentId, tutorId, scheduleId, rating, comment);
};

module.exports = {
  postReview,
};