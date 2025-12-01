const express = require('express');
const router = express.Router();
const tutorController = require('../controllers/tutorController');
const { protect, isTutor, isStudent } = require('../middleware/authMiddleware');


router.get('/', tutorController.searchTutors);  

router.get('/:tutorId', tutorController.getTutorProfile);

router.put('/my-profile', protect, isTutor, tutorController.updateMyTutorProfile);

router.get('/me/profile', protect, isTutor, tutorController.getMyTutorProfile);

router.get('/me/dashboard', protect, isTutor, tutorController.getDashboard);

router.get('/me/earnings', protect, isTutor, tutorController.getEarnings);

router.post('/me/withdraw', protect, isTutor, tutorController.requestWithdrawal);

module.exports = router;