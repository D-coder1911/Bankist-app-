const db = require('../config/db');

class LoanApproval {
    static async findPendingLoans() {
        const query = `CALL GetPendingLoans();`; 
        const [loans] = await db.query(query);
        return loans[0];  
    }

    static async updateLoanStatus(loanId, newStatus) {
        const query = `CALL UpdateLoanStatus(?, ?);`;  
        const [result] = await db.query(query, [loanId, newStatus]);
        return result;  
    }
}

module.exports = LoanApproval;
