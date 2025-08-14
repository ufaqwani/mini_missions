const db = require('../database/database');
const { v4: uuidv4 } = require('uuid');

class Mission {
  static getAll() {
    return new Promise((resolve, reject) => {
      db.all('SELECT * FROM missions ORDER BY created_at DESC', (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
  }

  static getById(id) {
    return new Promise((resolve, reject) => {
      db.get('SELECT * FROM missions WHERE id = ?', [id], (err, row) => {
        if (err) reject(err);
        else resolve(row);
      });
    });
  }

  static create(missionData) {
    return new Promise((resolve, reject) => {
      const id = uuidv4();
      const { title, description, target_completion_date } = missionData;
      
      db.run(
        'INSERT INTO missions (id, title, description, target_completion_date) VALUES (?, ?, ?, ?)',
        [id, title, description, target_completion_date],
        function(err) {
          if (err) reject(err);
          else resolve({ id, ...missionData });
        }
      );
    });
  }

  static update(id, missionData) {
    return new Promise((resolve, reject) => {
      const { title, description, status, target_completion_date } = missionData;
      const completed_at = status === 'completed' ? new Date().toISOString() : null;
      
      db.run(
        'UPDATE missions SET title = ?, description = ?, status = ?, target_completion_date = ?, completed_at = ? WHERE id = ?',
        [title, description, status, target_completion_date, completed_at, id],
        function(err) {
          if (err) reject(err);
          else resolve({ id, ...missionData });
        }
      );
    });
  }

  static delete(id) {
    return new Promise((resolve, reject) => {
      db.run('DELETE FROM missions WHERE id = ?', [id], function(err) {
        if (err) reject(err);
        else resolve({ deleted: this.changes > 0 });
      });
    });
  }
}

module.exports = Mission;
