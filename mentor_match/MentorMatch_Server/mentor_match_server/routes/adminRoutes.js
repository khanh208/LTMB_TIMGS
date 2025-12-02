const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const { protect, isAdmin } = require('../middleware/authMiddleware');

router.use(protect, isAdmin);

router.get('/tutors/pending', adminController.getPendingTutors);
router.get('/tutors/:tutorId', adminController.getTutorDetailForAdmin);
router.put('/tutors/:tutorId/verify', adminController.verifyTutor);
    
module.exports = router;