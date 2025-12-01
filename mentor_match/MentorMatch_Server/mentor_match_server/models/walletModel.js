// models/walletModel.js
const pool = require('../config/db');

const createWallet = async (userId) => {
  await pool.query(
    'INSERT INTO mentor_match.Wallets (user_id, balance) VALUES ($1, 0.00)',
    [userId]
  );
};

const findWalletByUserId = async (userId) => {
  const result = await pool.query(
    'SELECT * FROM mentor_match.Wallets WHERE user_id = $1',
    [userId]
  );
  return result.rows[0];
};

const updateBalance = async (walletId, newBalance) => {
  await pool.query(
    'UPDATE mentor_match.Wallets SET balance = $1 WHERE wallet_id = $2',
    [newBalance, walletId]
  );
};

const createTransaction = async (walletId, amount, type, description) => {
  const result = await pool.query(
    `INSERT INTO mentor_match.Transactions (wallet_id, amount, type, description)
     VALUES ($1, $2, $3, $4) RETURNING *`,
    [walletId, amount, type, description]
  );
  return result.rows[0];
};

const findTransactionsByWalletId = async (walletId) => {
  const result = await pool.query(
    `SELECT * FROM mentor_match.Transactions 
     WHERE wallet_id = $1 
     ORDER BY created_at DESC`,
    [walletId]
  );
  return result.rows;
};

const linkExternalAccount = async (userId, type, number, name) => {
  const result = await pool.query(
    `INSERT INTO mentor_match.ExternalAccounts (user_id, account_type, account_number, account_name, is_verified)
     VALUES ($1, $2, $3, $4, TRUE)
     RETURNING *`,
    [userId, type, number, name]  
  );
  return result.rows[0];
};

const getExternalAccounts = async (userId) => {
  const result = await pool.query(
    'SELECT * FROM mentor_match.ExternalAccounts WHERE user_id = $1',
    [userId]
  );
  return result.rows;
};

module.exports = {
  createWallet,
  findWalletByUserId,
  updateBalance,
  createTransaction,
  findTransactionsByWalletId,
  linkExternalAccount,
  getExternalAccounts,
};