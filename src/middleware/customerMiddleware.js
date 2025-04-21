const db = require('../config/db');

exports.customerMiddleware = async (req, res, next) => {
    try {
        const userId = req.user.id;

        const [results] = await db.query(`
            SELECT c.id
            FROM customer c
            WHERE c.id = ?`, 
            [userId]);

        if (results.length === 0) {
            return res.status(403).json({ msg: 'Access denied: Only Customers are allowed' });
        }

        next(); 
    } catch (error) {
        console.error(error);
        res.status(500).json({ msg: 'Server error during customer check' });
    }
};
