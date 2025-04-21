const db = require('../config/db');

exports.employeeMiddleware = async (req, res, next) => {
    try {
        const userId = req.user.id;

        const [results] = await db.query(`
            SELECT p.name
            FROM employee e
            JOIN position p ON e.position_id = p.id
            WHERE e.id = ? AND p.name NOT IN ('Branch Manager', 'Technician')`, 
            [userId]);

        if (results.length === 0) {
            return res.status(403).json({ msg: 'Access denied: Only Employees are allowed' });
        }

        next(); 
    } catch (error) {
        console.error(error);
        res.status(500).json({ msg: 'Server error during employee check' });
    }
};
