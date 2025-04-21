const db = require('../config/db'); 

class Report {
  static async getBranchTransactions(emp_id, start_date, end_date) {
    const [results] = await db.query(
      'CALL get_branch_transactions(?, ?, ?)', 
      [emp_id, start_date, end_date]
    );
    return results[1]; 
  }

  static async getLateLoanInstallments(emp_id) {
    const [results] = await db.query(
      'CALL branch_wise_late_installments(?)', 
      [emp_id] 
    );
    return results[1];
  }
}

module.exports = Report;
