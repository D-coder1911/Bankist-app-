const express = require('express');
const router = express.Router();
const { getAccountSummary } = require('../controllers/accountSummaryController');
const { authMiddleware } = require('../middleware/authMiddleware');
const { customerMiddleware } = require('../middleware/customerMiddleware');

router.get('/account-summary', authMiddleware, customerMiddleware, getAccountSummary);

module.exports = router;
