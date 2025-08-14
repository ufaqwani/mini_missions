const express = require('express');
const cors = require('cors');
const path = require('path');
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

// Serve static files from React build (for production)
if (process.env.NODE_ENV === 'production') {
  app.use(express.static(path.join(__dirname, '../frontend/build')));
  
  // Handle React routing - send all non-API requests to React app
  app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, '../frontend/build', 'index.html'));
  });
}

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'Mission Tracker is running!', 
    timestamp: new Date().toISOString(),
    auth: 'Simple 3-user system enabled',
    environment: process.env.NODE_ENV || 'development'
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Mission Tracker server running on port ${PORT}`);
  console.log(`🔐 Users: ufaq, zia, sweta`);
  console.log(`📱 Environment: ${process.env.NODE_ENV || 'development'}`);
});
