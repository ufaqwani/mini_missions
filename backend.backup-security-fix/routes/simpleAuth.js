const express = require('express');
const { loginUser } = require('../middleware/simpleAuth');

const router = express.Router();

// Login endpoint
router.post('/login', loginUser);

// Get available users (for development)
router.get('/users', (req, res) => {
  res.json({
    users: ['ufaq', 'zia', 'sweta'],
    message: 'Available users for login'
  });
});

module.exports = router;
