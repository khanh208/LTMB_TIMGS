const chatService = require('../services/chatService');

const getMyRooms = async (req, res) => {
  try {
    const userId = req.user.userId;
    const rooms = await chatService.getRooms(userId);
    res.status(200).json(rooms);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getMessages = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { roomId } = req.params;
    const messages = await chatService.getMessages(roomId, userId);
    res.status(200).json(messages);
  } catch (error) {
    res.status(403).json({ message: error.message });
  }
};

const sendMessage = async (req, res) => {
  try {
    const senderId = req.user.userId;
    const { roomId } = req.params;
    const { messageText } = req.body;
    
    if (!messageText) {
      return res.status(400).json({ message: 'Nội dung tin nhắn không được rỗng.' });
    }
    
    const newMessage = await chatService.sendMessage(roomId, senderId, messageText);
    res.status(201).json(newMessage);
  } catch (error) {
    res.status(403).json({ message: error.message });
  }
};

const markAsRead = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { roomId } = req.params;
    await chatService.markAsRead(roomId, userId);
    res.status(200).json({ message: 'Đã đánh dấu đã đọc.' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const connectWithTutor = async (req, res) => {
  try {
    const studentId = req.user.userId; 
    const { tutorId, messageText } = req.body;

    if (!tutorId || !messageText) {
      return res.status(400).json({ message: 'Thiếu tutorId hoặc nội dung tin nhắn.' });
    }

    const result = await chatService.connectWithTutor(studentId, tutorId, messageText);
    
    res.status(201).json({
      message: 'Kết nối thành công!',
      data: result
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const checkConnection = async (req, res) => {
  try {
    const myId = req.user.userId;
    const { targetUserId } = req.params;
    
    const result = await chatService.checkConnection(myId, targetUserId);
    res.status(200).json(result);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};  

module.exports = {
  getMyRooms,
  getMessages,
  sendMessage,
  connectWithTutor,
  markAsRead,
  checkConnection 
};