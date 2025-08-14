const express = require('express');
const router = express.Router();
const Mission = require('../models/Mission');

// Get all missions
router.get('/', async (req, res) => {
  try {
    const missions = await Mission.getAll();
    res.json(missions);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get mission by ID
router.get('/:id', async (req, res) => {
  try {
    const mission = await Mission.getById(req.params.id);
    if (!mission) {
      return res.status(404).json({ error: 'Mission not found' });
    }
    res.json(mission);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Create new mission
router.post('/', async (req, res) => {
  try {
    const mission = await Mission.create(req.body);
    res.status(201).json(mission);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update mission
router.put('/:id', async (req, res) => {
  try {
    const mission = await Mission.update(req.params.id, req.body);
    res.json(mission);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Delete mission
router.delete('/:id', async (req, res) => {
  try {
    const result = await Mission.delete(req.params.id);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
