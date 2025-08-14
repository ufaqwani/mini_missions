const express = require('express');
const router = express.Router();
const DailyMission = require('../models/DailyMission');

// Get all daily missions
router.get('/', async (req, res) => {
  try {
    const dailyMissions = await DailyMission.getAll();
    res.json(dailyMissions);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get daily missions by mission ID
router.get('/mission/:missionId', async (req, res) => {
  try {
    const dailyMissions = await DailyMission.getByMissionId(req.params.missionId);
    res.json(dailyMissions);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Create new daily mission
router.post('/', async (req, res) => {
  try {
    const dailyMission = await DailyMission.create(req.body);
    res.status(201).json(dailyMission);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update daily mission
router.put('/:id', async (req, res) => {
  try {
    const dailyMission = await DailyMission.update(req.params.id, req.body);
    res.json(dailyMission);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Delete daily mission
router.delete('/:id', async (req, res) => {
  try {
    const result = await DailyMission.delete(req.params.id);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
