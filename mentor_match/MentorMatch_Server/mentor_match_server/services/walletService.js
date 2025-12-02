// services/walletService.js
const walletModel = require('../models/walletModel');

const linkAccount = async (userId, { accountType, accountNumber, accountName }) => {
  if (!accountNumber || !accountName) {
    throw new Error('Thiếu thông tin tài khoản.');
  }
  return await walletModel.linkExternalAccount(userId, accountType, accountNumber, accountName);
};

const getLinkedAccounts = async (userId) => {
  return await walletModel.getExternalAccounts(userId);
};

const deposit = async (userId, amount, source) => {
  if (amount <= 0) throw new Error('Số tiền nạp phải lớn hơn 0.');
  
  // Kiểm tra liên kết ví
  const accounts = await walletModel.getExternalAccounts(userId);
  if (!accounts || accounts.length === 0) {
    throw new Error('Bạn chưa liên kết tài khoản thanh toán. Vui lòng liên kết trước.');
  }

  const wallet = await walletModel.findWalletByUserId(userId);
  if (!wallet) throw new Error('Không tìm thấy ví.');

  const client = await require('../config/db').connect();
  try {
    await client.query('BEGIN');
    
    // Tăng số dư
    const newBalance = parseFloat(wallet.balance) + parseFloat(amount);
    await walletModel.updateBalance(wallet.wallet_id, newBalance);
    
    // Ghi giao dịch
    const transaction = await walletModel.createTransaction(
        wallet.wallet_id, 
        amount, 
        'deposit', 
        `Nạp tiền từ ${source}`
    );
    
    await client.query('COMMIT');
    return { newBalance, transaction };
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }
};

const getBalance = async (userId) => {
  const wallet = await walletModel.findWalletByUserId(userId);
  return { balance: wallet.balance };
};

const getTransactions = async (userId) => {
  const wallet = await walletModel.findWalletByUserId(userId);
  return await walletModel.findTransactionsByWalletId(wallet.wallet_id);
};
    
module.exports = {
  linkAccount,
  deposit,
  getBalance,
  getTransactions,
  getLinkedAccounts,
};