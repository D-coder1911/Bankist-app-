const bcrypt = require('bcryptjs');
const { validationResult } = require('express-validator');
const { generateToken } = require('../utils/tokenUtil');
const Employee = require('../models/Employee');
const Customer = require('../models/Customer');

exports.login = async (req, res) => {
    const { username, password } = req.body;

    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    try {
        const employee = await Employee.findByUsername(username);
        const customer = await Customer.findByUsername(username);
        let position = null;

        let user = null;
        let userType = '';

        if (employee) {
            user = employee;
            position = await Employee.findPositionEmployee(username);
            if (position.position === 'Technician') userType = 'technician';
            else if (position.position === 'Branch Manager') userType = 'manager';
            else userType = 'employee'; 
        } else if (customer) {
            user = customer;
            userType = 'customer';
        }

        if (!user) {
            return res.status(400).json({ msg: 'User not found' });
        }

        const isMatched = await bcrypt.compare(password, user.password);
        if (!isMatched) {
            return res.status(400).json({ msg: 'Invalid credentials' });
        }

        user.userType = userType;
        const token = generateToken(user);

        res.json({ token, userType });
    } catch (error) {
        console.error(error.message);
        res.status(500).json({ msg: 'Server error during login' });
    }
};

exports.changePassword = async (req, res) => {
    const { oldPassword, newPassword } = req.body;
    const userId = req.user.id;

    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    try {
        const user = req.user.userType === 'employee' ? await Employee.findById(userId) : await Customer.findById(userId);

        if (!user) {
            return res.status(400).json({ msg: 'User not found' });
        }

        const isMatched = await bcrypt.compare(oldPassword, user.password);
        if (!isMatched) {
            return res.status(400).json({ msg: 'Invalid current password' });
        }

        const hashedPassword = await bcrypt.hash(newPassword, 10);

        if (req.user.userType === 'employee') {
            await Employee.updatePassword(userId, hashedPassword);
        } else {
            await Customer.updatePassword(userId, hashedPassword);
        }

        return res.json({ msg: 'Password updated successfully' });
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ msg: 'Server error during password update' });
    }
};

exports.changeName = async (req, res) => {
    const { newName, confirmNewName } = req.body;
    const userId = req.user.id;  // User from JWT token

    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    if (newName !== confirmNewName)
        return res.status(400).json({ msg: 'Name and confirm name do not match' });

    try {
        const nameParts = newName.split(' ');
        const firstName = nameParts[0];
        const lastName = nameParts.slice(1).join(' ');

        if (req.user.userType === 'employee') {
            await Employee.updateName(userId, firstName, lastName);
        } else {
            await Customer.updateName(userId, firstName, lastName);
        }

        return res.json({ msg: 'Name updated successfully' });
    } catch (error) {
        console.error(error.message);
        res.status(500).json({ msg: 'Server error during name update' });
    }
};

exports.changeAddress = async (req, res) => {
    const { newAddress } = req.body;
    const userId = req.user.id;

    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    try {
        if (req.user.userType === 'employee') {
            await Employee.updateAddress(userId, newAddress);
        } else {
            await Customer.updateAddress(userId, newAddress);
        }

        return res.json({ msg: 'Address updated successfully' });
    } catch (error) {
        console.error(error.message);
        res.status(500).json({ msg: 'Server error during address update' });
    }
};
