const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { poolPromise, sql } = require('../db/db');
const nodemailer = require('nodemailer');

// POST /signup
exports.signup = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Missing fields' });
  }

  try {
    const pool = await poolPromise;

    const existingUser = await pool.request()
      .input('email', sql.NVarChar, email)
      .query('SELECT id FROM users WHERE email = @email');

    if (existingUser.recordset.length > 0) {
      return res.status(400).json({ message: 'Email already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    await pool.request()
      .input('email', sql.NVarChar, email)
      .input('password', sql.NVarChar, hashedPassword)
      .query(`
        INSERT INTO users (email, password_hash)
        VALUES (@email, @password)
      `);

    res.json({ message: 'User registered successfully' });

  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
};

// POST /login
exports.login = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Missing fields' });
  }

  try {
    const pool = await poolPromise;

    const result = await pool.request()
      .input('email', sql.NVarChar, email)
      .query('SELECT * FROM users WHERE email = @email');

    if (result.recordset.length === 0) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const user = result.recordset[0];
    const isMatch = await bcrypt.compare(password, user.password_hash);

    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const token = jwt.sign(
      { userId: user.id },
      process.env.JWT_SECRET,
      { expiresIn: '1d' }
    );

    res.json({ token });

  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
};

// POST /forgot-password

exports.forgotPassword = async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ message: 'Email required' });

  try {
    const pool = await poolPromise;
    const result = await pool.request()
      .input('email', sql.NVarChar, email)
      .query('SELECT id FROM users WHERE email = @email');

    if (result.recordset.length === 0)
      return res.status(404).json({ message: 'Account not found' });

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiration = new Date(Date.now() + 5 * 60 * 1000); // 5 min

    await pool.request()
      .input('email', sql.NVarChar, email)
      .input('otp', sql.NVarChar, otp)
      .input('expiration', sql.DateTime, expiration)
      .query('UPDATE users SET otp=@otp, otp_expiration=@expiration WHERE email=@email');

    console.log('OTP for', email, otp);

    res.json({ message: 'OTP generated (check server logs)' });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// POST /reset-password
exports.resetPassword = async (req, res) => {
  const { email, otp, newPassword } = req.body;
  if (!email || !otp || !newPassword)
    return res.status(400).json({ message: 'Missing fields' });

  try {
    const pool = await poolPromise;
    const result = await pool.request()
      .input('email', sql.NVarChar, email)
      .query('SELECT otp, otp_expiration FROM users WHERE email=@email');

    if (result.recordset.length === 0)
      return res.status(404).json({ message: 'Account not found' });

    const user = result.recordset[0];
    if (user.otp !== otp || new Date(user.otp_expiration) < new Date()) {
      return res.status(400).json({ message: 'Invalid or expired OTP' });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);

    await pool.request()
      .input('email', sql.NVarChar, email)
      .input('password', sql.NVarChar, hashedPassword)
      .query('UPDATE users SET password_hash=@password, otp=NULL, otp_expiration=NULL WHERE email=@email');

    res.json({ message: 'Password reset successfully' });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};


