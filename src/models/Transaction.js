const db = require('../config/db');

class Transaction {
    static async getAllRecentTransactions(employeeId) {
        const query = 'CALL get_recent_transactions_for_branch(?);';
        const [transactions] = await db.query(query, [employeeId]);
        return transactions[0]; 
    }

    static async getAccountBalance(accountNumber) {
        const query = 'SELECT acc_balance FROM account WHERE account_number = ?';
        const [result] = await db.query(query, [accountNumber]);
        return result[0];
    }

    static async performTransaction({ customerId, fromAccount, toAccount, beneficiaryName, amount, receiverReference, myReference }) {
        const query = 'CALL DoTransaction(?, ?, ?, ?, ?, ?, ?)';
        await db.query(query, [customerId, fromAccount, toAccount, beneficiaryName, amount, receiverReference, myReference]);
    }
}

module.exports = Transaction;
