const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.join(__dirname, 'missions.db');
const db = new sqlite3.Database(dbPath);

// Initialize database tables
db.serialize(() => {
  // Main missions table
  db.run(`CREATE TABLE IF NOT EXISTS missions (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME,
    target_completion_date DATE
  )`);

  // Daily missions table
  db.run(`CREATE TABLE IF NOT EXISTS daily_missions (
    id TEXT PRIMARY KEY,
    mission_id TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME,
    due_date DATE,
    FOREIGN KEY (mission_id) REFERENCES missions (id) ON DELETE CASCADE
  )`);
});

module.exports = db;
