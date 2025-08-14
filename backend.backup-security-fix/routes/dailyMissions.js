const express = require('express');
const router = express.Router();
const DailyMission = require('../models/DailyMission');
const { authenticateUser } = require('../middleware/simpleAuth');

// Apply authentication to all routes
router.use(authenticateUser);

// Get all daily missions for authenticated user
router.get('/', async (req, res) => {
  try {
    const dailyMissions = await DailyMission.getAll(req.user.username);
    res.json(dailyMissions);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get daily missions by mission ID for authenticated user
router.get('/mission/:missionId', async (req, res) => {
  try {
    const dailyMissions = await DailyMission.getByMissionId(req.params.missionId, req.user.username);
    res.json(dailyMissions);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Create new daily mission for authenticated user
router.post('/', async (req, res) => {
  try {
    const dailyMission = await DailyMission.create(req.body, req.user.username);
    res.status(201).json(dailyMission);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update daily mission for authenticated user
router.put('/:id', async (req, res) => {
  try {
    const dailyMission = await DailyMission.update(req.params.id, req.body, req.user.username);
    res.json(dailyMission);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Delete daily mission for authenticated user
router.delete('/:id', async (req, res) => {
  try {
    const result = await DailyMission.delete(req.params.id, req.user.username);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
