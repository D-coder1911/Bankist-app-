const express = require('express');
const router = express.Router();
const { getAccounts } = require('../src/controllers/accountController');

router.get('/accounts', getAccounts);

module.exports = router;
