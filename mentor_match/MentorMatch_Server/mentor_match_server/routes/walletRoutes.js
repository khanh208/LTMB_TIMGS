const express = require('express');
const router = express.Router();
const walletController = require('../controllers/walletController');
const { protect } = require('../middleware/authMiddleware');

router.use(protect);

router.post('/link', walletController.linkAccount);
router.post('/deposit', walletController.deposit);
router.post('/mock-deposit', walletController.mockDeposit);
router.get('/balance', walletController.getBalance);
router.get('/transactions', walletController.getTransactions);
router.get('/accounts', walletController.getLinkedAccounts);

module.exports = router;