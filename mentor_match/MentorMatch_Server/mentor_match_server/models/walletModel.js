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

const findTransactionsByWalletId = async (walletId) => {
  const result = await pool.query(
    `SELECT * FROM mentor_match.Transactions 
     WHERE wallet_id = $1 
     ORDER BY created_at DESC`,
    [walletId]
  );
  return result.rows;
};

const createTransaction = async (walletId, amount, type, description) => {
  const result = await pool.query(
    `INSERT INTO mentor_match.Transactions (wallet_id, amount, type, description)
     VALUES ($1, $2, $3, $4) RETURNING *`,
    [walletId, amount, type, description]
  );
  return result.rows[0];
};

const updateBalance = async (walletId, newBalance) => {
  await pool.query(
    'UPDATE mentor_match.Wallets SET balance = $1 WHERE wallet_id = $2',
    [newBalance, walletId]
  );
};

module.exports = {
  createWallet,
  findWalletByUserId,
  findTransactionsByWalletId,
  createTransaction, 
  updateBalance, 
};