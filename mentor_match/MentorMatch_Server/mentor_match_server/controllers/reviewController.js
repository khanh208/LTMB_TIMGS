const reviewService = require('../services/reviewService');

const createReview = async (req, res) => {
  try {
    const studentId = req.user.userId;
    const reviewData = req.body;
    
    const newReview = await reviewService.postReview(studentId, reviewData);
    res.status(201).json(newReview);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

module.exports = {
  createReview,
};