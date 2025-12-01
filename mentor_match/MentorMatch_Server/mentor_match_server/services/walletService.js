const pool = require('../config/db');
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

const performDeposit = async ({
  userId,
  amount,
  description,
  requireLinkedAccount = true,
}) => {
  if (!amount || amount <= 0) {
    throw new Error('Số tiền nạp phải lớn hơn 0.');
  }

  if (requireLinkedAccount) {
  const accounts = await walletModel.getExternalAccounts(userId);
  if (!accounts || accounts.length === 0) {
    throw new Error('Bạn chưa liên kết tài khoản thanh toán. Vui lòng liên kết trước.');
    }
  }

  const wallet = await walletModel.findWalletByUserId(userId);
  if (!wallet) throw new Error('Không tìm thấy ví.');

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const newBalance = parseFloat(wallet.balance) + parseFloat(amount);
    await walletModel.updateBalance(wallet.wallet_id, newBalance);
    const transaction = await walletModel.createTransaction(
      wallet.wallet_id,
      amount,
      'deposit',
      description,
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

const deposit = async (userId, amount, source) => {
  return performDeposit({
    userId,
    amount,
    description: `Nạp tiền từ ${source}`,
    requireLinkedAccount: true,
  });
};

const mockDeposit = async (userId, amount) => {
  return performDeposit({
    userId,
    amount,
    description: 'Giả lập nạp tiền',
    requireLinkedAccount: false,
  });
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
  mockDeposit,
  getBalance,
  getTransactions,
  getLinkedAccounts,
};