const pool = require('../config/db');

const createRoom = async (userOneId, userTwoId) => {
  const result = await pool.query(
    `INSERT INTO mentor_match.ChatRooms (user_one_id, user_two_id) 
     VALUES ($1, $2) 
     ON CONFLICT (LEAST(user_one_id, user_two_id), GREATEST(user_one_id, user_two_id)) 
     DO UPDATE SET room_id = mentor_match.ChatRooms.room_id
     RETURNING *`,
    [userOneId, userTwoId]
  );
  return result.rows[0];
};

const findRoomsByUserId = async (userId) => {
  const result = await pool.query(
    `SELECT 
      R.room_id,
      CASE
        WHEN R.user_one_id = $1 THEN R.user_two_id
        ELSE R.user_one_id
      END AS recipient_id,
      U.full_name AS recipient_name,
      U.avatar_url AS recipient_avatar,
      
      (SELECT message_text FROM mentor_match.ChatMessages M 
       WHERE M.room_id = R.room_id ORDER BY M.sent_at DESC LIMIT 1) as last_message,
       
      (SELECT sent_at FROM mentor_match.ChatMessages M 
       WHERE M.room_id = R.room_id ORDER BY M.sent_at DESC LIMIT 1) as last_message_time,

      (SELECT COUNT(*)::int FROM mentor_match.ChatMessages M
       WHERE M.room_id = R.room_id 
       AND M.sender_user_id != $1 -- Tin nhắn không phải do mình gửi
       AND M.sent_at > ( -- Tin nhắn mới hơn lần xem cuối
          CASE 
            WHEN R.user_one_id = $1 THEN R.user_one_last_seen
            ELSE R.user_two_last_seen
          END
       )
      ) as unread_count

    FROM mentor_match.ChatRooms R
    JOIN mentor_match.Users U ON U.user_id = (
      CASE
        WHEN R.user_one_id = $1 THEN R.user_two_id
        ELSE R.user_one_id
      END
    )
    WHERE R.user_one_id = $1 OR R.user_two_id = $1
    ORDER BY last_message_time DESC NULLS LAST`,
    [userId]
  );
  return result.rows;
};

const findMessagesByRoomId = async (roomId) => {
  const result = await pool.query(
    `SELECT message_id, room_id, sender_user_id, message_text, sent_at
     FROM mentor_match.ChatMessages
     WHERE room_id = $1
     ORDER BY sent_at ASC`,
    [roomId]
  );
  return result.rows;
};

const sendMessage = async (roomId, senderId, messageText) => {
  const result = await pool.query(
    `INSERT INTO mentor_match.ChatMessages (room_id, sender_user_id, message_text)
     VALUES ($1, $2, $3) RETURNING *`,
    [roomId, senderId, messageText]
  );
  return result.rows[0];
};

const isUserInRoom = async (roomId, userId) => {
  const result = await pool.query(
    `SELECT 1 FROM mentor_match.ChatRooms 
     WHERE room_id = $1 AND (user_one_id = $2 OR user_two_id = $2)`,
    [roomId, userId]
  );
  return result.rows.length > 0;
};

const markRoomAsRead = async (roomId, userId) => {
  await pool.query(
    `UPDATE mentor_match.ChatRooms
     SET 
       user_one_last_seen = CASE WHEN user_one_id = $2 THEN NOW() ELSE user_one_last_seen END,
       user_two_last_seen = CASE WHEN user_two_id = $2 THEN NOW() ELSE user_two_last_seen END
     WHERE room_id = $1`,
    [roomId, userId]
  );
};

const findRoomBetweenUsers = async (userA, userB) => {
  const result = await pool.query(
    `SELECT room_id FROM mentor_match.ChatRooms 
     WHERE (user_one_id = $1 AND user_two_id = $2) 
        OR (user_one_id = $2 AND user_two_id = $1)`,
    [userA, userB]
  );
  return result.rows[0]; 
};

module.exports = {
  createRoom,
  findRoomsByUserId,
  findMessagesByRoomId,
  sendMessage,
  isUserInRoom,
  markRoomAsRead,
  findRoomBetweenUsers,
};  