const express = require('express');
const router = express.Router();

// Debug endpoint to check all daily missions and their completion status
router.get('/daily-missions', async (req, res) => {
  try {
    const db = require('../database/database');
    
    const allMissions = await new Promise((resolve, reject) => {
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
    
    res.json({
      total: allMissions.length,
      completed: allMissions.filter(m => m.status === 'completed').length,
      pending: allMissions.filter(m => m.status === 'pending').length,
      missions: allMissions
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
