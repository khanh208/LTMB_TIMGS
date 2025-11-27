const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const userModel = require('../models/userModel');
const walletModel = require('../models/walletModel');
const tutorModel = require('../models/tutorModel');

const register = async (email, password, fullName, role) => {
  const existingUser = await userModel.findUserByEmail(email);
  if (existingUser) {
    throw new Error('Email đã được sử dụng.');
  }

  const salt = await bcrypt.genSalt(10);
  const hashedPassword = await bcrypt.hash(password, salt);

  const newUser = await userModel.createUser(email, hashedPassword, fullName, role);

  await walletModel.createWallet(newUser.user_id);

  if (role === 'tutor') {
    await tutorModel.createProfile(newUser.user_id);
  }

  const token = jwt.sign(
    { userId: newUser.user_id, role: newUser.role },
    process.env.JWT_SECRET,
    { expiresIn: '1d' }
  );

  return { user: newUser, token };
};

const login = async (email, password) => {
  const user = await userModel.findUserByEmail(email);
  if (!user) {
    throw new Error('Email hoặc mật khẩu không chính xác.');
  }

  const isValidPassword = await bcrypt.compare(password, user.password_hash);
  if (!isValidPassword) {
    throw new Error('Email hoặc mật khẩu không chính xác.');
  }

  const token = jwt.sign(
    { userId: user.user_id, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: '1d' }
  );

  return { user, token };
};

module.exports = {
  register,
  login,
};