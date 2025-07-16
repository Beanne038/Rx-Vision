const jwt = require('jsonwebtoken');

function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    console.log("🔒 No token provided");
    return res.status(401).json({ success: false, message: 'Access token missing' });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      console.log("❌ Invalid or expired token");
      return res.status(403).json({ success: false, message: 'Invalid or expired token' });
    }

    req.user = user;
    next();
  });
}

module.exports = authenticateToken;
