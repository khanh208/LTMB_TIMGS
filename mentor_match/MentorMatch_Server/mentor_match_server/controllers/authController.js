const authService = require('../services/authService');

const register = async (req, res) => {
  try {
    const { email, password, fullName, role } = req.body;

    if (!email || !password || !fullName || !role) {
      return res.status(400).json({ message: 'Vui lòng điền đầy đủ thông tin.' });
    }
    if (role !== 'student' && role !== 'tutor') {
      return res.status(400).json({ message: 'Vai trò không hợp lệ.' });
    }

    const { user, token } = await authService.register(email, password, fullName, role);
    
    user.password_hash = undefined;

    res.status(201).json({ user, token, message: 'Đăng ký thành công!' });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Vui lòng nhập email và mật khẩu.' });
    }

    const { user, token } = await authService.login(email, password);

    user.password_hash = undefined;
    
    res.status(200).json({ user, token, message: 'Đăng nhập thành công!' });
  } catch (error) {
    res.status(401).json({ message: error.message }); 
  }
};

const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ message: 'Vui lòng nhập email.' });
    }

    res.status(200).json({ message: 'Nếu email tồn tại, bạn sẽ nhận được hướng dẫn đặt lại mật khẩu.' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  register,
  login,
  forgotPassword,
};