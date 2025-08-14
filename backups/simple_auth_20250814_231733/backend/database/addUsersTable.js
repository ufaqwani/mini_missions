const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.join(__dirname, 'missions.db');
const db = new sqlite3.Database(dbPath);

db.serialize(() => {
  // Create users table
  db.run(`CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  )`, (err) => {
    if (err) {
      console.error('Error creating users table:', err);
    } else {
      console.log('Users table created successfully');
    }
  });

  // Add user_id column to missions table
  db.run(`ALTER TABLE missions ADD COLUMN user_id TEXT`, (err) => {
    if (err && !err.message.includes('duplicate column')) {
      console.error('Error adding user_id to missions:', err);
    } else {
      console.log('Added user_id to missions table');
    }
  });

  // Add user_id column to daily_missions table
  db.run(`ALTER TABLE daily_missions ADD COLUMN user_id TEXT`, (err) => {
    if (err && !err.message.includes('duplicate column')) {
      console.error('Error adding user_id to daily_missions:', err);
    } else {
      console.log('Added user_id to daily_missions table');
    }
  });
});

db.close();
