// controllers/walletController.js
const walletService = require('../services/walletService');

const linkAccount = async (req, res) => {
  try {
    const userId = req.user.userId;
    const result = await walletService.linkAccount(userId, req.body);
    res.status(201).json(result);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const deposit = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { amount, source } = req.body;
    const result = await walletService.deposit(userId, amount, source);
    res.status(200).json(result);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const getBalance = async (req, res) => {
  try {
    const userId = req.user.userId;
    const result = await walletService.getBalance(userId);
    res.status(200).json(result);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getTransactions = async (req, res) => {
  try {
    const userId = req.user.userId;
    const result = await walletService.getTransactions(userId);
    res.status(200).json(result);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getLinkedAccounts = async (req, res) => {
  try {
    const userId = req.user.userId;
    const accounts = await walletService.getLinkedAccounts(userId);
    res.status(200).json(accounts);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  linkAccount,
  deposit,
  getBalance,
  getTransactions,
  getLinkedAccounts,
};