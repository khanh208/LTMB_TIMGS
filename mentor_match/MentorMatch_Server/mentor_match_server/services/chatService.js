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
  const room = await chatModel.createRoom(studentId, tutorId);
  
  const message = await chatModel.sendMessage(room.room_id, studentId, firstMessage);
  
  return {
    room,
    message
  };
};

const checkConnection = async (myId, targetUserId) => {
  const room = await chatModel.findRoomBetweenUsers(myId, targetUserId);
  if (room) {
    return { isConnected: true, roomId: room.room_id };
  } else {
    return { isConnected: false, roomId: null };
  }
};

module.exports = {
  getRooms,
  getMessages,
  sendMessage,
  connectWithTutor,
  markAsRead,
  checkConnection
};