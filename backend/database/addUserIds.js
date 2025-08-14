const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.join(__dirname, 'missions.db');
const db = new sqlite3.Database(dbPath);

db.serialize(() => {
  // Add user_id column to missions table
  db.run(`ALTER TABLE missions ADD COLUMN user_id TEXT DEFAULT 'ufaq'`, (err) => {
    if (err && !err.message.includes('duplicate column')) {
      console.error('Error adding user_id to missions:', err);
    } else {
      console.log('Added user_id to missions table');
    }
  });

  // Add user_id column to daily_missions table
  db.run(`ALTER TABLE daily_missions ADD COLUMN user_id TEXT DEFAULT 'ufaq'`, (err) => {
    if (err && !err.message.includes('duplicate column')) {
      console.error('Error adding user_id to daily_missions:', err);
    } else {
      console.log('Added user_id to daily_missions table');
    }
  });
});

db.close();
