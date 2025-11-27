const express = require('express');
const router = express.Router();
const reviewController = require('../controllers/reviewController');
const { protect, isStudent } = require('../middleware/authMiddleware');

router.post('/', protect, isStudent, reviewController.createReview);

module.exports = router;