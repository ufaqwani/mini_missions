const db = require('../database/database');
const { v4: uuidv4 } = require('uuid');

class DailyMission {
  static getAll() {
    return new Promise((resolve, reject) => {
      db.all(`
        SELECT dm.*, m.title as mission_title 
        FROM daily_missions dm 
        JOIN missions m ON dm.mission_id = m.id 
        ORDER BY dm.created_at DESC
      `, (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
  }

  static getByMissionId(missionId) {
    return new Promise((resolve, reject) => {
      db.all(
        'SELECT * FROM daily_missions WHERE mission_id = ? ORDER BY created_at DESC',
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
      const { mission_id, title, description, due_date } = dailyMissionData;
      
      db.run(
        'INSERT INTO daily_missions (id, mission_id, title, description, due_date) VALUES (?, ?, ?, ?, ?)',
        [id, mission_id, title, description, due_date],
        function(err) {
          if (err) reject(err);
          else resolve({ id, ...dailyMissionData });
        }
      );
    });
  }

  static update(id, dailyMissionData) {
    return new Promise((resolve, reject) => {
      const { title, description, status, due_date } = dailyMissionData;
      const completed_at = status === 'completed' ? new Date().toISOString() : null;
      
      db.run(
        'UPDATE daily_missions SET title = ?, description = ?, status = ?, due_date = ?, completed_at = ? WHERE id = ?',
        [title, description, status, due_date, completed_at, id],
        function(err) {
          if (err) reject(err);
          else resolve({ id, ...dailyMissionData });
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
