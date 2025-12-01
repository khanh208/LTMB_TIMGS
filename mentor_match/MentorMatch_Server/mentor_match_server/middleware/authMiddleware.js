const jwt = require('jsonwebtoken');

const protect = (req, res, next) => {
  let token;
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    try {
      token = req.headers.authorization.split(' ')[1];
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      req.user = decoded; 
      next(); 
    } catch (error) {
      res.status(401).json({ message: 'Token không hợp lệ hoặc đã hết hạn.' });
    }
  }

  if (!token) {
    res.status(401).json({ message: 'Chưa đăng nhập, không có token.' });
  }
};

const isTutor = (req, res, next) => {
  if (req.user && req.user.role === 'tutor') {
    next();
  } else {
    res.status(403).json({ message: 'Yêu cầu quyền Gia sư.' });
  }
};

const isStudent = (req, res, next) => {
  if (req.user && req.user.role === 'student') {
    next();
  } else {
    res.status(403).json({ message: 'Yêu cầu quyền Học viên.' });
  }
};

module.exports = { protect, isTutor, isStudent };