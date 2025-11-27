const express = require('express');
const router = express.Router();
const tutorController = require('../controllers/tutorController');
const { protect, isTutor, isStudent } = require('../middleware/authMiddleware');


// GET /api/tutors/ 
router.get('/', tutorController.searchTutors);  

// GET /api/tutors/:tutorId 
router.get('/:tutorId', tutorController.getTutorProfile);

// PUT /api/tutors/my-profile 
router.put('/my-profile', protect, isTutor, tutorController.updateMyTutorProfile);

// GET /api/tutors/me/dashboard
router.get('/me/dashboard', protect, isTutor, tutorController.getDashboard);

// GET /api/tutors/me/earnings
router.get('/me/earnings', protect, isTutor, tutorController.getEarnings);

// POST /api/tutors/me/withdraw
router.post('/me/withdraw', protect, isTutor, tutorController.requestWithdrawal);

module.exports = router;