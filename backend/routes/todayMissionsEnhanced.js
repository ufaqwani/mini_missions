const express = require('express');
const router = express.Router();

// Enhanced today missions with overdue detection
router.get('/enhanced', async (req, res) => {
  try {
    const today = new Date().toISOString().split('T')[0];
    const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString().split('T')[0];
    
    const todayMissions = await new Promise((resolve, reject) => {
      const db = require('../database/database');
      db.all(`
        SELECT dm.*, 
               m.title as mission_title, 
               m.status as mission_status,
               CASE 
                 WHEN dm.due_date < ? THEN 'overdue'
                 WHEN dm.due_date = ? THEN 'today'
                 ELSE 'future'
               END as task_status,
               CASE 
                 WHEN dm.due_date < ? THEN julianday(?) - julianday(dm.due_date)
                 ELSE 0
               END as days_overdue
        FROM daily_missions dm 
        JOIN missions m ON dm.mission_id = m.id 
        WHERE (dm.due_date <= ? OR dm.due_date IS NULL) 
        AND dm.status != 'completed' 
        AND m.status = 'active'
        ORDER BY dm.priority ASC, 
                 CASE WHEN dm.due_date < ? THEN 0 ELSE 1 END,
                 dm.due_date ASC, 
                 dm.created_at DESC
      `, [today, today, today, today, today, today], (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
    
    res.json(todayMissions);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
