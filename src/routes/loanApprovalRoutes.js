const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/authMiddleware');
const { branchManagerMiddleware } = require('../middleware/branchManagerMiddleware');
const { getPendingLoans, updateLoanStatus } = require('../controllers/loanApprovalController');

router.get('/pending-loans', authMiddleware, branchManagerMiddleware, getPendingLoans);

router.put('/update-loan-status', authMiddleware, branchManagerMiddleware, updateLoanStatus);

module.exports = router;
