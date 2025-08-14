const express = require('express');
const router = express.Router();
const DailyMission = require('../models/DailyMission');

// Get today's missions (due today or overdue) sorted by priority
router.get('/', async (req, res) => {
  try {
    const today = new Date().toISOString().split('T')[0]; // YYYY-MM-DD format
    
    const todayMissions = await new Promise((resolve, reject) => {
      const db = require('../database/database');
      db.all(`
        SELECT dm.*, m.title as mission_title, m.status as mission_status
        FROM daily_missions dm 
        JOIN missions m ON dm.mission_id = m.id 
        WHERE (dm.due_date <= ? OR dm.due_date IS NULL) 
        AND dm.status != 'completed' 
        AND m.status = 'active'
        ORDER BY dm.priority ASC, dm.due_date ASC, dm.created_at DESC
      `, [today], (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
    
    res.json(todayMissions);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get today's completed missions with priority info
router.get('/completed', async (req, res) => {
  try {
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const tomorrow = new Date(today.getTime() + 24 * 60 * 60 * 1000);
    
    const todayStart = today.toISOString();
    const todayEnd = tomorrow.toISOString();
    
    const completedToday = await new Promise((resolve, reject) => {
      const db = require('../database/database');
      db.all(`
        SELECT dm.*, m.title as mission_title
        FROM daily_missions dm 
        JOIN missions m ON dm.mission_id = m.id 
        WHERE dm.status = 'completed' 
        AND dm.completed_at >= ? 
        AND dm.completed_at < ?
        ORDER BY dm.completed_at DESC
      `, [todayStart, todayEnd], (err, rows) => {
        if (err) {
          console.error('Database error:', err);
          reject(err);
        } else {
          resolve(rows);
        }
      });
    });
    
    res.json(completedToday);
  } catch (error) {
    console.error('Error in /completed route:', error);
    res.status(500).json({ error: error.message });
  }
});

// Quick add today's mission with priority
router.post('/quick-add', async (req, res) => {
  try {
    const { title, mission_id, priority = 2 } = req.body;
    const today = new Date().toISOString().split('T')[0];
    
    const dailyMissionData = {
      mission_id: mission_id,
      title: title,
      description: '',
      due_date: today,
      priority: priority
    };
    
    const dailyMission = await DailyMission.create(dailyMissionData);
    res.status(201).json(dailyMission);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
