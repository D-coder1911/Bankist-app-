const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/authMiddleware');
const { getCustomerLoans, requestLoan, getLoanDetails, requestLoanByEmployee, getLoanTypes } = require('../controllers/loanController');
const { requestLoanValidation } = require('../validations/loanValidation'); 
const { customerMiddleware } = require('../middleware/customerMiddleware'); 
const { employeeMiddleware } = require('../middleware/employeeMiddleware');

router.get('/customer-loans', authMiddleware, getCustomerLoans);

router.post('/request-loan', authMiddleware, customerMiddleware, requestLoanValidation, requestLoan);

router.get('/loan-details/:id', authMiddleware, customerMiddleware, getLoanDetails);

router.post('/request-loan-emp', authMiddleware, employeeMiddleware, requestLoanByEmployee);

router.get('/types', authMiddleware, employeeMiddleware, getLoanTypes);

module.exports = router;
