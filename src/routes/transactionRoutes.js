const express = require('express');
const { getAllRecentTransactions, doTransaction, getRecentTransactionsByBranchId, getRecentTransactionsByCustomerId, getRecentTransactionsByCustomerIdAndAccountNumber } = require('../controllers/transactionController');
const { authMiddleware } = require('../middleware/authMiddleware');
const { transactionValidation } = require('../validations/transactionValidation');
const { employeeMiddleware } = require('../middleware/employeeMiddleware');
const { customerMiddleware } = require('../middleware/customerMiddleware');
const { branchManagerMiddleware } = require('../middleware/branchManagerMiddleware');
const router = express.Router();

router.get('/recent-transactions', authMiddleware, employeeMiddleware, getAllRecentTransactions);

router.post('/do-transaction', authMiddleware, customerMiddleware, transactionValidation, doTransaction);

router.get('/recent-by-branch/:branchId', authMiddleware, branchManagerMiddleware, getRecentTransactionsByBranchId);

router.get('/recent-by-customer/:customerId', authMiddleware, customerMiddleware, getRecentTransactionsByCustomerId);

router.get('/recent-by-customer', authMiddleware, customerMiddleware, getRecentTransactionsByCustomerIdAndAccountNumber);

module.exports = router;
