const { verifyToken } = require('../utils/tokenUtil');

exports.authMiddleware = (req, res, next) => {
    const token = req.header('Authorization')?.split(' ')[1]; 
    if (!token) {
        return res.status(401).json({ msg: 'token not found, authorization failed' });  
    }

    try {
        const decoded = verifyToken(token); 
        req.user = decoded; 
        next();
        
    } catch (error) {
        res.status(401).json({ msg: 'token is not valid'})
    }
}