const chatModel = require('../models/chatModel');

const getRooms = async (userId) => {
  return await chatModel.findRoomsByUserId(userId);
};

const getMessages = async (roomId, userId) => {
  const userInRoom = await chatModel.isUserInRoom(roomId, userId);
  if (!userInRoom) {
    throw new Error('Không có quyền truy cập phòng chat này.');
  }
  return await chatModel.findMessagesByRoomId(roomId);
};

const sendMessage = async (roomId, senderId, messageText) => {
  const userInRoom = await chatModel.isUserInRoom(roomId, senderId);
  if (!userInRoom) {
    throw new Error('Không có quyền gửi tin nhắn vào phòng này.');
  }
  return await chatModel.sendMessage(roomId, senderId, messageText);
};

const markAsRead = async (roomId, userId) => {
  const userInRoom = await chatModel.isUserInRoom(roomId, userId);
  if (!userInRoom) {
    throw new Error('Không có quyền truy cập phòng này.');
  }
  await chatModel.markRoomAsRead(roomId, userId);
};

const connectWithTutor = async (studentId, tutorId, firstMessage) => {
  // 1. Tự động tạo phòng (hoặc lấy phòng cũ nếu đã có)
  // Hàm createRoom trong model đã có logic "ON CONFLICT DO NOTHING" nên rất an toàn
  const room = await chatModel.createRoom(studentId, tutorId);
  
  // 2. Gửi tin nhắn đầu tiên vào phòng đó
  const message = await chatModel.sendMessage(room.room_id, studentId, firstMessage);
  
  return {
    room,
    message
  };
};

module.exports = {
  getRooms,
  getMessages,
  sendMessage,
  connectWithTutor,
  markAsRead
};