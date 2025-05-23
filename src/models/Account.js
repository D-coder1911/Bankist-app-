const db = require('../config/db');

class Account {
    static async findByCustomerId(customerId) {
        const query = `CALL GetCustomerAccountSummary(?)`;
        const [accounts] = await db.query(query, [customerId]);
        return accounts[0]; 
    }
    static async openAccount(account_type_id, customer_id, initial_deposit, employee_id) {
        const query = `
            INSERT INTO account (customer_id, account_type_id, branch_id, acc_balance) 
            VALUES (?, ?, (SELECT branch_id FROM general_employee WHERE employee_id = ?), ?)`;
        const [results] = await db.query(query, [customer_id, account_type_id, employee_id, initial_deposit]);
        return results;
    };

    static async findOne({ where: { account_number } }) {
        const query = `SELECT * FROM account WHERE account_number = ?`;
        const [account] = await db.query(query, [account_number]);
        return account[0]; 
    };
}

module.exports = Account;
