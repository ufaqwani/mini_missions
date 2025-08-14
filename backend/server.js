const express = require('express');
const cors = require('cors');
require('./database/database'); // Initialize database

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Authentication routes (public)
app.use('/api/auth', require('./routes/simpleAuth'));

// Protected routes (require authentication)
app.use('/api/missions', require('./routes/missions'));
app.use('/api/daily-missions', require('./routes/dailyMissions'));
app.use('/api/today', require('./routes/todayMissions'));

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'Server is running!', 
    timestamp: new Date().toISOString(),
    auth: 'Simple 3-user system enabled'
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Mission Tracker server running on port ${PORT}`);
  console.log(`🔐 Simple authentication: ufaq, zia, sweta`);
});
