const express = require('express');
const router = express.Router();
const scheduleController = require('../controllers/scheduleController');
const { protect } = require('../middleware/authMiddleware');

router.use(protect);

// GET /api/schedule/ 
router.get('/', scheduleController.getMySchedule);

// POST /api/schedule/ 
router.post('/', scheduleController.createSchedule);

// PUT /api/schedule/:scheduleId 
router.put('/:scheduleId', scheduleController.updateSchedule);

module.exports = router;