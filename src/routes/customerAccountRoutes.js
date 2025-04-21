const express = require('express');
const router = express.Router();
const { getCustomerAccountsByBranch, getBranchIdOfEmployee, getAccountSummaries, getAccountTypes, getCustomerDetails } = require('../controllers/customerAccountController');
const { openAccount } = require('../controllers/customerAccountController');
const { authMiddleware } = require('../middleware/authMiddleware');
const { employeeMiddleware } = require('../middleware/employeeMiddleware');

router.get('/summaries/branch/:branchId', authMiddleware, employeeMiddleware, getCustomerAccountsByBranch);

router.get('/employee/branch-id', authMiddleware, employeeMiddleware, getBranchIdOfEmployee);

router.get('/account-summaries/:emp_id', authMiddleware, employeeMiddleware, getAccountSummaries);

router.get('/account-types', authMiddleware, employeeMiddleware, getAccountTypes);

router.get('/customer-details', authMiddleware, employeeMiddleware, getCustomerDetails);

router.post('/open-account', authMiddleware, employeeMiddleware, openAccount);

module.exports = router;
