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

async function logAudit(userId, action) {
  try {
    await pool.query("INSERT INTO audit_logs (user_id, action) VALUES (?, ?)", [userId, action]);
  } catch (err) {
    console.error("Audit log error:", err);
  }
}

// ✅ Registration
app.post('/api/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;
    if (!name?.trim() || !email?.trim() || !password?.trim()) {
      return res.status(400).json({ success: false, message: 'All fields are required' });
    }
    const [existing] = await pool.query('SELECT id FROM users WHERE email = ?', [email]);
    if (existing.length > 0) {
      return res.status(400).json({ success: false, message: 'Email already exists' });
    }
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    const [result] = await pool.query(
      'INSERT INTO users (name, email, password) VALUES (?, ?, ?)',
      [name, email, hashedPassword]
    );
    await logAudit(result.insertId, 'User registered');
    res.status(201).json({ success: true, message: 'Registration successful', userId: result.insertId });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// ✅ Login
app.post('/api/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email?.trim() || !password?.trim()) {
      return res.status(400).json({ success: false, message: 'Email and password are required' });
    }
    const [users] = await pool.query('SELECT id, name, email, password FROM users WHERE email = ?', [email]);
    if (users.length === 0) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }
    const user = users[0];
    const passwordMatch = await bcrypt.compare(password, user.password);
    if (!passwordMatch) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }
    const token = jwt.sign({ id: user.id, name: user.name, email: user.email }, process.env.JWT_SECRET, { expiresIn: '1h' });
    await logAudit(user.id, 'User logged in');
    res.json({ success: true, message: 'Login successful', token, user: { id: user.id, name: user.name, email: user.email } });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

app.get('/api/users/profile', authenticateToken, async (req, res) => {
  const userId = req.user.id;
  try {
    const [rows] = await pool.query('SELECT id, name, email FROM users WHERE id = ?', [userId]);
    if (rows.length > 0) {
      res.status(200).json({ success: true, user: rows[0] });
    } else {
      res.status(404).json({ success: false, message: 'User not found' });
    }
  } catch (error) {
    console.error('User profile fetch error:', error);
    res.status(500).json({ success: false, message: 'Database error' });
  }
});

app.put('/api/users/email', authenticateToken, async (req, res) => {
  const { email } = req.body;
  const userId = req.user.id;

  if (!email) return res.status(400).json({ success: false, message: 'Email is required' });

  try {
    await pool.query('UPDATE users SET email = ? WHERE id = ?', [email, userId]);
    res.status(200).json({ success: true, message: 'Email updated successfully' });
  } catch (error) {
    console.error('Error updating email:', error);
    res.status(500).json({ success: false, message: 'Database error' });
  }
});

app.put('/api/users/name', authenticateToken, async (req, res) => {
  const { name } = req.body;
  const userId = req.user.id;

  if (!name?.trim()) {
    return res.status(400).json({ success: false, message: 'Name is required' });
  }

  try {
    const [result] = await pool.query('UPDATE users SET name = ? WHERE id = ?', [name, userId]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, message: 'User not found or name unchanged' });
    }

    await logAudit(userId, 'User updated name');

    const [rows] = await pool.query('SELECT id, name, email FROM users WHERE id = ?', [userId]);

    res.status(200).json({ success: true, message: 'Name updated successfully', user: rows[0] });
  } catch (error) {
    console.error('Error updating name:', error);
    res.status(500).json({ success: false, message: 'Database error' });
  }
});

// ✅ Change Password Route (POST /api/users/change-password)
app.post('/api/users/change-password', authenticateToken, async (req, res) => {
  const userId = req.user.id;
  const { currentPassword, newPassword } = req.body;

  if (!currentPassword || !newPassword) {
    return res.status(400).json({ message: 'Missing required fields.' });
  }

  try {
    const [results] = await pool.query('SELECT password FROM users WHERE id = ?', [userId]);

    if (results.length === 0) {
      return res.status(404).json({ message: 'User not found.' });
    }

    const user = results[0];
    const match = await bcrypt.compare(currentPassword, user.password);

    if (!match) {
      return res.status(401).json({ message: 'Current password is incorrect.' });
    }

    const hashedNewPassword = await bcrypt.hash(newPassword, 10);
    await pool.query('UPDATE users SET password = ? WHERE id = ?', [hashedNewPassword, userId]);

    // Tell the client to log out and clear token
    res.status(200).json({
      message: 'Password changed successfully. Please log in again.',
      forceLogout: true
    });
  } catch (error) {
    console.error('Unexpected error:', error);
    res.status(500).json({ message: 'Something went wrong.' });
  }
});

// ✅ Reset Password Route (POST /api/reset-password)
app.post('/api/reset-password', async (req, res) => {
  const { email, newPassword } = req.body;

  if (!email || !newPassword) {
    return res.status(400).json({ message: 'Email and password are required.' });
  }

  try {
    const [results] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);

    if (results.length === 0) {
      return res.status(404).json({ message: 'User not found.' });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);

    await pool.query('UPDATE users SET password = ? WHERE email = ?', [hashedPassword, email]);

    return res.json({ message: 'Password updated successfully.' });
  } catch (err) {
    console.error('Error resetting password:', err);
    return res.status(500).json({ message: 'Internal server error.' });
  }
});


// ✅ Prescription: View
app.get('/api/prescriptions', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM prescriptions');
    res.json({ success: true, prescriptions: rows });
  } catch (error) {
    console.error('Fetch prescriptions error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// ✅ Prescription: Add
app.post('/api/prescriptions', async (req, res) => {
  try {
    const { patient_name, doctor_name, date, medication, dosage, instructions } = req.body;
    if (!patient_name?.trim() || !doctor_name?.trim() || !date?.trim() || !medication?.trim() || !dosage?.trim() || !instructions?.trim()) {
      return res.status(400).json({ success: false, message: 'All fields are required' });
    }
    await pool.query(
      'INSERT INTO prescriptions (patient_name, doctor_name, date, medication, dosage, instructions) VALUES (?, ?, ?, ?, ?, ?)',
      [patient_name, doctor_name, date, medication, dosage, instructions]
    );
    res.status(201).json({ success: true, message: 'Prescription added successfully' });
  } catch (error) {
    console.error('Add prescription error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// ✅ Prescription: Delete
app.delete('/api/prescriptions/:id', async (req, res) => {
  try {
    const { id } = req.params;
    await pool.query('DELETE FROM prescriptions WHERE id = ?', [id]);
    res.json({ success: true, message: 'Prescription marked as dispensed' });
  } catch (error) {
    console.error('Delete prescription error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// ✅ Supplier: View
app.get('/api/suppliers', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM suppliers');
    res.json({ success: true, suppliers: rows });
  } catch (error) {
    console.error('Fetch suppliers error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// ✅ Supplier: Add
app.post('/api/suppliers', async (req, res) => {
  try {
    const { name, contact_person, contact_number, email, address, last_delivery, product_type } = req.body;
    if (!name?.trim() || !contact_person?.trim() || !contact_number?.trim() || !email?.trim() || !product_type?.trim()) {
      return res.status(400).json({ success: false, message: 'All required fields must be filled' });
    }
    await pool.query(
      'INSERT INTO suppliers (name, contact_person, contact_number, email, address, last_delivery, product_type) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [name, contact_person, contact_number, email, address || null, last_delivery || null, product_type]
    );
    res.status(201).json({ success: true, message: 'Supplier added successfully' });
  } catch (error) {
    console.error('Add supplier error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// ✅ Supplier: Update
app.put('/api/suppliers/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, contact_person, contact_number, email, address, last_delivery, product_type } = req.body;
    if (!name?.trim() || !contact_person?.trim() || !contact_number?.trim() || !email?.trim() || !product_type?.trim()) {
      return res.status(400).json({ success: false, message: 'All required fields must be filled' });
    }
    await pool.query(
      'UPDATE suppliers SET name = ?, contact_person = ?, contact_number = ?, email = ?, address = ?, last_delivery = ?, product_type = ? WHERE id = ?',
      [name, contact_person, contact_number, email, address || null, last_delivery || null, product_type, id]
    );
    res.json({ success: true, message: 'Supplier updated successfully' });
  } catch (error) {
    console.error('Update supplier error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// ✅ Supplier: Delete
app.delete('/api/suppliers/:id', async (req, res) => {
  try {
    const { id } = req.params;
    await pool.query('DELETE FROM suppliers WHERE id = ?', [id]);
    res.json({ success: true, message: 'Supplier deleted successfully' });
  } catch (error) {
    console.error('Delete supplier error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// ✅ Inventory: View
app.get('/api/inventory', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT inventory.*, suppliers.name AS supplier_name 
      FROM inventory 
      LEFT JOIN suppliers ON inventory.supplier_id = suppliers.id
    `);
    res.json({ success: true, inventory: rows });
  } catch (error) {
    console.error('Fetch inventory error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});


// ✅ Inventory: Add
app.post('/api/inventory', async (req, res) => {
  try {
    const { item_name, quantity, date_received, supplier_id } = req.body;
    if (!item_name?.trim() || !quantity || !date_received?.trim() || !supplier_id) {
      return res.status(400).json({ success: false, message: 'All fields are required' });
    }
    await pool.query(
      'INSERT INTO inventory (item_name, quantity, date_received, supplier_id) VALUES (?, ?, ?, ?)',
      [item_name, quantity, date_received, supplier_id]
    );
    res.status(201).json({ success: true, message: 'Inventory added successfully' });
  } catch (error) {
    console.error('Add inventory error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// ✅ Inventory: Update
app.put('/api/inventory/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { item_name, quantity, date_received, supplier_id } = req.body;
    if (!item_name?.trim() || quantity == null || !date_received?.trim() || !supplier_id) {
      return res.status(400).json({ success: false, message: 'All fields are required' });
    }
    await pool.query(
      'UPDATE inventory SET item_name = ?, quantity = ?, date_received = ?, supplier_id = ? WHERE id = ?',
      [item_name, quantity, date_received, supplier_id, id]
    );
    res.json({ success: true, message: 'Inventory updated successfully' });
  } catch (error) {
    console.error('Update inventory error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// ✅ Inventory: Delete
app.delete('/api/inventory/:id', async (req, res) => {
  try {
    const { id } = req.params;
    await pool.query('DELETE FROM inventory WHERE id = ?', [id]);
    res.json({ success: true, message: 'Inventory deleted successfully' });
  } catch (error) {
    console.error('Delete inventory error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// POST Notification
app.post('/api/notifications', async (req, res) => {
  try {
    const { title, message } = req.body;
    await pool.query('INSERT INTO notifications (title, message) VALUES (?, ?)', [title, message]);
    res.status(201).json({ success: true });
  } catch (err) {
    console.error('Notification Error:', err);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// ✅ GET notifications
app.get('/api/notifications', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM notifications ORDER BY created_at DESC');
    res.json({ success: true, notifications: rows });
  } catch (err) {
    console.error('Fetch notifications error:', err);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

app.delete('/api/notifications/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const [result] = await pool.query('DELETE FROM notifications WHERE id = ?', [id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, message: 'Notification not found' });
    }

    res.json({ success: true, message: 'Notification deleted successfully' });
  } catch (error) {
    console.error('Delete notification error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});


// ✅ Get user by ID
app.get('/api/users/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await pool.query('SELECT id, name, email FROM users WHERE id = ?', [id]);

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    res.json({ success: true, user: rows[0] });
  } catch (error) {
    console.error('Fetch user error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// ✅ Start server
const PORT = 3000;
app.listen(3000, '0.0.0.0', () => {
  console.log('Server running on http://0.0.0.0:3000');
});



