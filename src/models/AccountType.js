const db = require('../config/db');

class AccountType {
    static async findAll() {
        const query = `SELECT * FROM account_type`;
        const [accountTypes] = await db.query(query);
        
        return accountTypes;
    }
}

module.exports = AccountType;