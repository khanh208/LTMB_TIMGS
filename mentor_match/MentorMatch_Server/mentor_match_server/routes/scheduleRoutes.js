// routes/scheduleRoutes.js
const express = require('express');
const router = express.Router();
const scheduleController = require('../controllers/scheduleController');
const { protect, isTutor, isStudent } = require('../middleware/authMiddleware');

router.use(protect);

router.get('/', scheduleController.getMySchedule);
router.post('/proposal', isTutor, scheduleController.createProposal);
router.get('/proposal/:groupId', scheduleController.getProposal);
router.post('/payment', isStudent, scheduleController.confirmPayment);
router.put('/:scheduleId', scheduleController.updateStatus);
router.post('/reject', protect, scheduleController.rejectProposal);

module.exports = router;