import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-production';
const JWT_EXPIRES_IN = '24h';

export async function hashPassword(password) {
  return await bcrypt.hash(password, 12);
}

export async function verifyPassword(password, hashedPassword) {
  return await bcrypt.compare(password, hashedPassword);
}

export function generateToken(user) {
  return jwt.sign(
    { 
      id: user.id, 
      username: user.username, 
      role: user.role,
      name: user.full_name 
    },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES_IN }
  );
}

export function verifyToken(token) {
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch (error) {
    return null;
  }
}

export async function authenticateUser(username, password) {
  const { query } = await import('./db.js');
  
  const users = await query(
    'SELECT * FROM users WHERE username = ? AND is_active = TRUE',
    [username]
  );
  
  if (users.length === 0) return null;
  
  const user = users[0];
  const isValid = await verifyPassword(password, user.password);
  
  if (!isValid) return null;
  
  const { password: _, ...userWithoutPassword } = user;
  return userWithoutPassword;
}