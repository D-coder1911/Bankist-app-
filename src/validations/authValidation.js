const { check } = require('express-validator');

exports.loginValidation = [
    check('username', 'username is required').not().isEmpty(),
    check('password', 'password is required').not().isEmpty(),
];

exports.changePasswordValidation = [
    check('oldPassword', 'current password is required').not().isEmpty(),
    check('newPassword', 'new password is required and must be at least 6 charactors long').isLength({ min: 6 }),
];

exports.changeNameValidation = [
    check('newName', 'new name is required').not().isEmpty(),
    check('confirmNewName', 'confirm name is required').not().isEmpty(),
];

exports.changeAddressValidation = [
    check('newAddress', 'address is required').not().isEmpty(),
];