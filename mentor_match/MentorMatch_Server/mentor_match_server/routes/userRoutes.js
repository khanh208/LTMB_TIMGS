const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { protect, isStudent } = require('../middleware/authMiddleware');

router.use(protect); 

router.get('/me', userController.getMyProfile); 

router.put('/me', userController.updateMyProfile);

router.put('/change-password', userController.changePassword);

router.get('/wallet', userController.getWallet);

router.post('/wallet/deposit', userController.requestDeposit);

router.get('/saved-tutors', isStudent, userController.getSavedTutors);

router.post('/saved-tutors', isStudent, userController.saveTutor);

router.delete('/saved-tutors/:tutorId', isStudent, userController.unsaveTutor);

router.post('/avatar', protect, userController.uploadAvatar);

module.exports = router;