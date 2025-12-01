const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');
const { protect } = require('../middleware/authMiddleware');

router.use(protect);

router.get('/rooms', chatController.getMyRooms);
router.get('/rooms/:roomId', chatController.getMessages);
router.post('/rooms/:roomId', chatController.sendMessage);
router.post('/connect', chatController.connectWithTutor);
router.put('/rooms/:roomId/read', chatController.markAsRead);
router.get('/check/:targetUserId', chatController.checkConnection);

module.exports = router;