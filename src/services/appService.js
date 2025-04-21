const express = require('express');
const dotenv = require('dotenv');
const authRoutes = require('../routes/authRoutes');
const loanRoutes = require('../routes/loanRoutes');
const branchManagementRoutes = require('../routes/branchManagementRoutes');
const customerAccountRoutes = require('../routes/customerAccountRoutes');
const employeeRoutes = require('../routes/employeeRoutes');
const employeeRoutesForTechnician = require('../routes/employeeRoutesForTechnician');
const branchManagerRoutes = require('../routes/branchManagerRoutes');
const loanApprovalRoutes = require('../routes/loanApprovalRoutes');
const accountSummaryRoutes = require('../routes/accountSummaryRoutes'); 
const transactionRoutes = require('../routes/transactionRoutes');

dotenv.config();
const app = express();

app.use(express.json()); 

app.use('/auth', authRoutes);

app.use('/loans', loanRoutes);

app.use('/transactions', transactionRoutes);

app.use('/branch-management', branchManagementRoutes);

app.use('/employee', employeeRoutes);

app.use('/customer-account', customerAccountRoutes);

app.use('/branch-manager', branchManagerRoutes);

app.use('/employee-management', employeeRoutesForTechnician);

app.use('/loan-approval', loanApprovalRoutes);

app.use('/accounts', accountSummaryRoutes); 


module.exports = app;