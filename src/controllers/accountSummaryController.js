const Account = require('../models/Account');

exports.getAccountSummary = async (req, res) => {
    const customerId = req.user.id;  
    try {
        const accounts = await Account.findByCustomerId(customerId);

        if (accounts.length === 0) {
            return res.status(404).json({ msg: 'No accounts found for this customer' });
        }

        res.json({
            customerId: customerId,
            accounts: accounts
        });
    } catch (error) {
        console.error('Error fetching account summary:', error);
        res.status(500).json({ msg: 'Server error while fetching account summary' });
    }
};
