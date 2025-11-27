const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { protect, isStudent } = require('../middleware/authMiddleware');

router.use(protect); 

// GET /api/users/me 
router.get('/me', userController.getMyProfile); 

// PUT /api/users/me 
router.put('/me', userController.updateMyProfile);

// PUT /api/users/change-password
router.put('/change-password', userController.changePassword);

// GET /api/users/wallet
router.get('/wallet', userController.getWallet);

// POST /api/users/wallet/deposit
router.post('/wallet/deposit', userController.requestDeposit);

// GET /api/users/saved-tutors
router.get('/saved-tutors', isStudent, userController.getSavedTutors);

// POST /api/users/saved-tutors
router.post('/saved-tutors', isStudent, userController.saveTutor);

// DELETE /api/users/saved-tutors/:tutorId
router.delete('/saved-tutors/:tutorId', isStudent, userController.unsaveTutor);

// POST /api/users/avatar (Gửi JSON body: { "avatarBase64": "..." })
router.post('/avatar', protect, userController.uploadAvatar);

module.exports = router;