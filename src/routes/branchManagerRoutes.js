const express = require('express');
const router = express.Router();
const { getBranchManagerById, updateBranchOfManager, getBranchIdByManager, getPositions, getBranchOfManager } = require('../controllers/branchManagerController');
const { getTransactionReport, getLateLoanReport } = require('../controllers/reportController');
const { authMiddleware } = require('../middleware/authMiddleware');
const { branchManagerMiddleware } = require('../middleware/branchManagerMiddleware');
const { route } = require('./authRoutes');

router.get('/get-branch/:id', authMiddleware, branchManagerMiddleware, getBranchManagerById); 

router.get('/get-branch-details', authMiddleware, branchManagerMiddleware, getBranchOfManager); 

router.get('/get-positions', authMiddleware, branchManagerMiddleware, getPositions); 

router.get('/get-branch-id', authMiddleware, branchManagerMiddleware, getBranchIdByManager); 

router.put('/update-branch-details/:id', authMiddleware, branchManagerMiddleware, updateBranchOfManager); 

router.get('/transaction-report', authMiddleware, branchManagerMiddleware, getTransactionReport); 

router.get('/late-loan-report', authMiddleware, branchManagerMiddleware, getLateLoanReport);  

module.exports = router;
