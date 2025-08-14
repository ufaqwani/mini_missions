const db = require('../database/database');
const { v4: uuidv4 } = require('uuid');

class Mission {
  static getAll(userId = 'ufaq') {
    return new Promise((resolve, reject) => {
      db.all('SELECT * FROM missions WHERE user_id = ? ORDER BY created_at DESC', [userId], (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
  }

  static getById(id, userId = 'ufaq') {
    return new Promise((resolve, reject) => {
      db.get('SELECT * FROM missions WHERE id = ? AND user_id = ?', [id, userId], (err, row) => {
        if (err) reject(err);
        else resolve(row);
      });
    });
  }

  static create(missionData, userId = 'ufaq') {
    return new Promise((resolve, reject) => {
      const id = uuidv4();
      const { title, description, target_completion_date } = missionData;
      
      db.run(
        'INSERT INTO missions (id, title, description, target_completion_date, user_id) VALUES (?, ?, ?, ?, ?)',
        [id, title, description, target_completion_date, userId],
        function(err) {
          if (err) reject(err);
          else resolve({ id, ...missionData, user_id: userId });
        }
      );
    });
  }

  static update(id, missionData, userId = 'ufaq') {
    return new Promise((resolve, reject) => {
      const { title, description, status, target_completion_date } = missionData;
      const completed_at = status === 'completed' ? new Date().toISOString() : null;
      
      db.run(
        'UPDATE missions SET title = ?, description = ?, status = ?, target_completion_date = ?, completed_at = ? WHERE id = ? AND user_id = ?',
        [title, description, status, target_completion_date, completed_at, id, userId],
        function(err) {
          if (err) reject(err);
          else resolve({ id, ...missionData });
        }
      );
    });
  }

  static delete(id, userId = 'ufaq') {
    return new Promise((resolve, reject) => {
      db.run('DELETE FROM missions WHERE id = ? AND user_id = ?', [id, userId], function(err) {
        if (err) reject(err);
        else resolve({ deleted: this.changes > 0 });
      });
    });
  }
}

module.exports = Mission;
