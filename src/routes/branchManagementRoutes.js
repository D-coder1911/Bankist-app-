const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/authMiddleware');
const { technicianMiddleware } = require('../middleware/technicianMiddleware');
const { getBranches, addBranch, updateBranch, removeBranch } = require('../controllers/branchController');

router.get('/branches', authMiddleware, technicianMiddleware, getBranches);

router.post('/add-branch', authMiddleware, technicianMiddleware, addBranch);

router.put('/update-branch', authMiddleware, technicianMiddleware, updateBranch);

router.delete('/remove-branch/:id', authMiddleware, technicianMiddleware, removeBranch);

module.exports = router;