const express = require('express');
const { loginUser } = require('../middleware/simpleAuth');

const router = express.Router();

// Secure login endpoint - NO password exposure
router.post('/login', loginUser);

// Health check - NO sensitive data
router.get('/health', (req, res) => {
  res.json({
    status: 'Authentication service active',
    timestamp: new Date().toISOString()
    // NO user list or password hints
  });
});

module.exports = router;
