const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/authMiddleware');
const { getEmployees, updateEmployeeFromId, getGeneralEmployeesByBranchId, getManagerEmployeesByBranchId, getEmployee, deleteEmployee } = require('../controllers/employeeController');
const { branchManagerMiddleware } = require('../middleware/branchManagerMiddleware');

router.get('/get-employees', authMiddleware, branchManagerMiddleware, getEmployees);  

router.get('/get-employee/:id', authMiddleware, branchManagerMiddleware, getEmployee); 

router.get('/general/branch/:branchId', authMiddleware, branchManagerMiddleware, getGeneralEmployeesByBranchId); 

router.get('/manager/branch/:branchId', authMiddleware, branchManagerMiddleware, getManagerEmployeesByBranchId); 

router.put('/update/:id', authMiddleware, branchManagerMiddleware, updateEmployeeFromId); 

router.delete('/delete/:id', authMiddleware, branchManagerMiddleware, deleteEmployee); 

module.exports = router;
