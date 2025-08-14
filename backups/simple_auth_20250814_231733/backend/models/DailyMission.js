const db = require('../database/database');
const { v4: uuidv4 } = require('uuid');

class DailyMission {
  static getAll() {
    return new Promise((resolve, reject) => {
      db.all(`
        SELECT dm.*, m.title as mission_title 
        FROM daily_missions dm 
        JOIN missions m ON dm.mission_id = m.id 
        ORDER BY dm.priority ASC, dm.created_at DESC
      `, (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
  }

  static getByMissionId(missionId) {
    return new Promise((resolve, reject) => {
      db.all(
        'SELECT * FROM daily_missions WHERE mission_id = ? ORDER BY priority ASC, created_at DESC',
        [missionId],
        (err, rows) => {
          if (err) reject(err);
          else resolve(rows);
        }
      );
    });
  }

  static create(dailyMissionData) {
    return new Promise((resolve, reject) => {
      const id = uuidv4();
      const { mission_id, title, description, due_date, priority = 2 } = dailyMissionData;
      
      db.run(
        'INSERT INTO daily_missions (id, mission_id, title, description, due_date, priority) VALUES (?, ?, ?, ?, ?, ?)',
        [id, mission_id, title, description, due_date, priority],
        function(err) {
          if (err) reject(err);
          else resolve({ id, ...dailyMissionData, priority });
        }
      );
    });
  }

  static update(id, dailyMissionData) {
    return new Promise((resolve, reject) => {
      const { title, description, status, due_date, priority = 2 } = dailyMissionData;
      
      // Set completed_at timestamp when status changes to completed
      let completed_at = null;
      if (status === 'completed') {
        completed_at = new Date().toISOString();
      }
      
      db.run(
        'UPDATE daily_missions SET title = ?, description = ?, status = ?, due_date = ?, priority = ?, completed_at = ? WHERE id = ?',
        [title, description, status, due_date, priority, completed_at, id],
        function(err) {
          if (err) reject(err);
          else resolve({ id, ...dailyMissionData, priority, completed_at });
        }
      );
    });
  }

  static delete(id) {
    return new Promise((resolve, reject) => {
      db.run('DELETE FROM daily_missions WHERE id = ?', [id], function(err) {
        if (err) reject(err);
        else resolve({ deleted: this.changes > 0 });
      });
    });
  }
}

module.exports = DailyMission;
