const express = require('express');
const cors = require('cors');
const path = require('path');
require('./database/database');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// API routes
app.use('/api/auth', require('./routes/simpleAuth'));
app.use('/api/missions', require('./routes/missions'));
app.use('/api/daily-missions', require('./routes/dailyMissions'));
app.use('/api/today', require('./routes/todayMissions'));

// Serve React app in production
if (process.env.NODE_ENV === 'production') {
  app.use(express.static(path.join(__dirname, '../frontend/build')));
  
  app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, '../frontend/build', 'index.html'));
  });
}

app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'Mission Tracker is running!',
    users: 'ufaq, zia, sweta'
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Mission Tracker running on port ${PORT}`);
});
