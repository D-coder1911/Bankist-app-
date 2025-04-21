const jwt = require('jsonwebtoken');


exports.generateToken = (user) => {
    return jwt.sign(
        {
            id: user.id,
            username: user.username,
            email: user.email,
            userType: user.userType,
        },
        process.env.JWT_SECRET,
        {
            expiresIn: '1h',  
        }
    );
};
 
exports.verifyToken = (token) => {
    return jwt.verify(token, process.env.JWT_SECRET); 
}