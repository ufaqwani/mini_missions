const express = require('express');
const router = express.Router();
const Mission = require('../models/Mission');
const { authenticateUser } = require('../middleware/simpleAuth');

// Apply authentication to all routes
router.use(authenticateUser);

// Get all missions for authenticated user
router.get('/', async (req, res) => {
  try {
    const missions = await Mission.getAll(req.user.username);
    res.json(missions);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get mission by ID for authenticated user
router.get('/:id', async (req, res) => {
  try {
    const mission = await Mission.getById(req.params.id, req.user.username);
    if (!mission) {
      return res.status(404).json({ error: 'Mission not found' });
    }
    res.json(mission);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Create new mission for authenticated user
router.post('/', async (req, res) => {
  try {
    const mission = await Mission.create(req.body, req.user.username);
    res.status(201).json(mission);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update mission for authenticated user
router.put('/:id', async (req, res) => {
  try {
    const mission = await Mission.update(req.params.id, req.body, req.user.username);
    res.json(mission);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Delete mission for authenticated user
router.delete('/:id', async (req, res) => {
  try {
    const result = await Mission.delete(req.params.id, req.user.username);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
