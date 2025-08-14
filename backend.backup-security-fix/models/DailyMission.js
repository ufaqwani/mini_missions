const db = require('../database/database');
const { v4: uuidv4 } = require('uuid');

class DailyMission {
  static getAll(userId = 'ufaq') {
    return new Promise((resolve, reject) => {
      db.all(`
        SELECT dm.*, m.title as mission_title 
        FROM daily_missions dm 
        JOIN missions m ON dm.mission_id = m.id 
        WHERE dm.user_id = ?
        ORDER BY dm.priority ASC, dm.created_at DESC
      `, [userId], (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
  }

  static getByMissionId(missionId, userId = 'ufaq') {
    return new Promise((resolve, reject) => {
      db.all(
        'SELECT * FROM daily_missions WHERE mission_id = ? AND user_id = ? ORDER BY priority ASC, created_at DESC',
        [missionId, userId],
        (err, rows) => {
          if (err) reject(err);
          else resolve(rows);
        }
      );
    });
  }

  static create(dailyMissionData, userId = 'ufaq') {
    return new Promise((resolve, reject) => {
      const id = uuidv4();
      const { mission_id, title, description, due_date, priority = 2 } = dailyMissionData;
      
      db.run(
        'INSERT INTO daily_missions (id, mission_id, title, description, due_date, priority, user_id) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [id, mission_id, title, description, due_date, priority, userId],
        function(err) {
          if (err) reject(err);
          else resolve({ id, ...dailyMissionData, priority, user_id: userId });
        }
      );
    });
  }

  static update(id, dailyMissionData, userId = 'ufaq') {
    return new Promise((resolve, reject) => {
      const { title, description, status, due_date, priority = 2 } = dailyMissionData;
      
      let completed_at = null;
      if (status === 'completed') {
        completed_at = new Date().toISOString();
      }
      
      db.run(
        'UPDATE daily_missions SET title = ?, description = ?, status = ?, due_date = ?, priority = ?, completed_at = ? WHERE id = ? AND user_id = ?',
        [title, description, status, due_date, priority, completed_at, id, userId],
        function(err) {
          if (err) reject(err);
          else resolve({ id, ...dailyMissionData, priority, completed_at });
        }
      );
    });
  }

  static delete(id, userId = 'ufaq') {
    return new Promise((resolve, reject) => {
      db.run('DELETE FROM daily_missions WHERE id = ? AND user_id = ?', [id, userId], function(err) {
        if (err) reject(err);
        else resolve({ deleted: this.changes > 0 });
      });
    });
  }
}

module.exports = DailyMission;
