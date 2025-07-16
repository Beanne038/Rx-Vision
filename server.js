require('dotenv').config();
const express = require('express');
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
const bodyParser = require('body-parser');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const rateLimit = require('express-rate-limit');
const authenticateToken = require('./authMiddleware');

const app = express();
app.use(cors());
app.use(bodyParser.json());

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  message: 'Too many requests, please try again later.'
});

app.use('/api/register', authLimiter);
app.use('/api/login', authLimiter);

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

const saltRounds = 12;

// ✅ Audit logging function
async function logAudit(userId, action) {
  try {
    await pool.query("INSERT INTO audit_logs (user_id, action) VALUES (?, ?)", [userId, action]);
  } catch (err) {
    console.error("Audit log error:", err);
  }
}

// ✅ Registration Endpoint with audit logging
app.post('/api/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ 
        success: false,
        message: 'All fields are required' 
      });
    }

    const [existing] = await pool.query(
      'SELECT id FROM users WHERE email = ?', 
      [email]
    );

    if (existing.length > 0) {
      return res.status(400).json({ 
        success: false,
        message: 'Email already exists' 
      });
    }

    const hashedPassword = await bcrypt.hash(password, saltRounds);

    const [result] = await pool.query(
      'INSERT INTO users (name, email, password) VALUES (?, ?, ?)',
      [name, email, hashedPassword]
    );

    // ✅ Audit log for registration
    await logAudit(result.insertId, 'User registered');

    res.status(201).json({ 
      success: true,
      message: 'Registration successful',
      userId: result.insertId 
    });

  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ 
      success: false,
      message: 'Internal server error' 
    });
  }
});

// ✅ Login Endpoint with audit logging
app.post('/api/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ 
        success: false,
        message: 'Email and password are required' 
      });
    }

    const [users] = await pool.query(
      'SELECT id, name, email, password FROM users WHERE email = ?', 
      [email]
    );

    if (users.length === 0) {
      return res.status(401).json({ 
        success: false,
        message: 'Invalid credentials' 
      });
    }

    const user = users[0];
    const passwordMatch = await bcrypt.compare(password, user.password);

    if (!passwordMatch) {
      return res.status(401).json({ 
        success: false,
        message: 'Invalid credentials' 
      });
    }

    const token = jwt.sign(
      { id: user.id, name: user.name, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '1h' }
    );

    // ✅ Audit log for login
    await logAudit(user.id, 'User logged in');

    res.json({ 
      success: true,
      message: 'Login successful',
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email
      }
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ 
      success: false,
      message: 'Internal server error' 
    });
  }
});

app.get('/api/some-private-data', authenticateToken, (req, res) => {
  res.json({ message: "Secure data", user: req.user });
});

const PORT = 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

