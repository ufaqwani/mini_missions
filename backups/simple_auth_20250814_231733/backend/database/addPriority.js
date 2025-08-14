const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.join(__dirname, 'missions.db');
const db = new sqlite3.Database(dbPath);

db.serialize(() => {
  // Add priority column to daily_missions table (default to medium priority)
  db.run(`ALTER TABLE daily_missions ADD COLUMN priority INTEGER DEFAULT 2`, (err) => {
    if (err && !err.message.includes('duplicate column')) {
      console.error('Error adding priority column:', err);
    } else {
      console.log('Priority column added successfully');
    }
  });
});

db.close();
