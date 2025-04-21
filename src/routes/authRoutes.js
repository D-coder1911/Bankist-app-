const express = require('express');
const { login, changePassword, changeName, changeAddress } = require('../controllers/authController');
const { loginValidation, changePasswordValidation, changeNameValidation, changeAddressValidation } = require('../validations/authValidation');
const { authMiddleware } = require('../middleware/authMiddleware');

const router = express.Router(); 

router.post('/login', loginValidation, login);

router.post('/change-password', authMiddleware, changePasswordValidation, changePassword);

router.post('/change-name', authMiddleware, changeNameValidation, changeName);

router.post('/change-address', authMiddleware, changeAddressValidation, changeAddress);

module.exports = router;
