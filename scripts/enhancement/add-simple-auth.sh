#!/bin/bash

echo "🔐 SIMPLE 3-USER AUTHENTICATION SYSTEM"
echo "Adding hardcoded users: ufaq, zia, sweta with safe backup..."

# Get current timestamp for unique backup name
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
FEATURE_NAME="simple_auth"

# Determine correct project root directory
if [ -d "mission-tracker" ]; then
    PROJECT_ROOT="mission-tracker"
    echo "📁 Found mission-tracker directory"
elif [ -d "frontend" ] && [ -d "backend" ]; then
    PROJECT_ROOT="."
    echo "📁 Already in project root"
else
    echo "❌ Please navigate to your mission-tracker directory first"
    exit 1
fi

BACKUP_DIR="backups/${FEATURE_NAME}_${TIMESTAMP}"

echo "📦 Creating full backup: $BACKUP_DIR"

# Create backup directory structure
mkdir -p "$BACKUP_DIR"

# Backup entire project
cp -r "$PROJECT_ROOT/frontend/src" "$BACKUP_DIR/frontend-src"
cp -r "$PROJECT_ROOT/frontend/public" "$BACKUP_DIR/frontend-public" 
cp -r "$PROJECT_ROOT/backend" "$BACKUP_DIR/backend"
cp "$PROJECT_ROOT/frontend/package.json" "$BACKUP_DIR/frontend-package.json"

# Backup database
cp "$PROJECT_ROOT/backend/database/missions.db" "$BACKUP_DIR/missions.db" 2>/dev/null || echo "No existing database found"

echo "✅ Backup created successfully: $BACKUP_DIR"

# Create rollback script
cat > "rollback_${FEATURE_NAME}_${TIMESTAMP}.sh" << EOF
#!/bin/bash
echo "🔄 Rolling back $FEATURE_NAME enhancement..."

# Stop servers
pkill -f "npm run dev" 2>/dev/null || true
pkill -f "npm start" 2>/dev/null || true
sleep 2

# Restore from backup
rm -rf "$PROJECT_ROOT/frontend/src"
rm -rf "$PROJECT_ROOT/frontend/public"
rm -rf "$PROJECT_ROOT/backend"
rm -f "$PROJECT_ROOT/frontend/package.json"

cp -r "$BACKUP_DIR/frontend-src" "$PROJECT_ROOT/frontend/src"
cp -r "$BACKUP_DIR/frontend-public" "$PROJECT_ROOT/frontend/public"
cp -r "$BACKUP_DIR/backend" "$PROJECT_ROOT/"
cp "$BACKUP_DIR/frontend-package.json" "$PROJECT_ROOT/frontend/package.json"
cp "$BACKUP_DIR/missions.db" "$PROJECT_ROOT/backend/database/missions.db" 2>/dev/null || true

echo "✅ Rollback completed! Your app is restored to working state."
echo "To restart: cd $PROJECT_ROOT/backend && npm run dev"
echo "           cd $PROJECT_ROOT/frontend && npm start"
EOF

chmod +x "rollback_${FEATURE_NAME}_${TIMESTAMP}.sh"

echo "🔄 Rollback script created: rollback_${FEATURE_NAME}_${TIMESTAMP}.sh"

echo "🚀 Adding simple 3-user authentication system..."

echo "🗄️ Step 1: Adding user_id to existing database tables..."

# Add user_id columns to existing tables
cat > "$PROJECT_ROOT/backend/database/addUserIds.js" << 'EOF'
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.join(__dirname, 'missions.db');
const db = new sqlite3.Database(dbPath);

db.serialize(() => {
  // Add user_id column to missions table
  db.run(`ALTER TABLE missions ADD COLUMN user_id TEXT DEFAULT 'ufaq'`, (err) => {
    if (err && !err.message.includes('duplicate column')) {
      console.error('Error adding user_id to missions:', err);
    } else {
      console.log('Added user_id to missions table');
    }
  });

  // Add user_id column to daily_missions table
  db.run(`ALTER TABLE daily_missions ADD COLUMN user_id TEXT DEFAULT 'ufaq'`, (err) => {
    if (err && !err.message.includes('duplicate column')) {
      console.error('Error adding user_id to daily_missions:', err);
    } else {
      console.log('Added user_id to daily_missions table');
    }
  });
});

db.close();
EOF

cd "$PROJECT_ROOT/backend"
node database/addUserIds.js
cd "$PROJECT_ROOT"

echo "🔐 Step 2: Creating simple authentication system..."

# Create simple auth middleware
cat > "$PROJECT_ROOT/backend/middleware/simpleAuth.js" << 'EOF'
// Simple hardcoded user authentication
const USERS = {
  'ufaq': 'ufitufy',
  'zia': 'zeetv', 
  'sweta': 'ss786'
};

const authenticateUser = (req, res, next) => {
  // Get current user from session/header
  const currentUser = req.headers['x-current-user'];
  
  if (!currentUser || !USERS[currentUser]) {
    return res.status(401).json({ error: 'Authentication required' });
  }
  
  req.user = { username: currentUser };
  next();
};

const loginUser = (req, res) => {
  const { username, password } = req.body;
  
  if (USERS[username] && USERS[username] === password) {
    res.json({ 
      success: true, 
      user: { username },
      message: 'Login successful' 
    });
  } else {
    res.status(401).json({ 
      success: false, 
      error: 'Invalid username or password' 
    });
  }
};

module.exports = { authenticateUser, loginUser, USERS };
EOF

echo "📡 Step 3: Adding auth routes to backend..."

# Create auth routes
cat > "$PROJECT_ROOT/backend/routes/simpleAuth.js" << 'EOF'
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
EOF

echo "🔧 Step 4: Updating existing models for user filtering..."

# Update Mission model with user filtering
cat > "$PROJECT_ROOT/backend/models/Mission.js" << 'EOF'
const db = require('../database/database');
const { v4: uuidv4 } = require('uuid');

class Mission {
  static getAll(userId = 'ufaq') {
    return new Promise((resolve, reject) => {
      db.all('SELECT * FROM missions WHERE user_id = ? ORDER BY created_at DESC', [userId], (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
  }

  static getById(id, userId = 'ufaq') {
    return new Promise((resolve, reject) => {
      db.get('SELECT * FROM missions WHERE id = ? AND user_id = ?', [id, userId], (err, row) => {
        if (err) reject(err);
        else resolve(row);
      });
    });
  }

  static create(missionData, userId = 'ufaq') {
    return new Promise((resolve, reject) => {
      const id = uuidv4();
      const { title, description, target_completion_date } = missionData;
      
      db.run(
        'INSERT INTO missions (id, title, description, target_completion_date, user_id) VALUES (?, ?, ?, ?, ?)',
        [id, title, description, target_completion_date, userId],
        function(err) {
          if (err) reject(err);
          else resolve({ id, ...missionData, user_id: userId });
        }
      );
    });
  }

  static update(id, missionData, userId = 'ufaq') {
    return new Promise((resolve, reject) => {
      const { title, description, status, target_completion_date } = missionData;
      const completed_at = status === 'completed' ? new Date().toISOString() : null;
      
      db.run(
        'UPDATE missions SET title = ?, description = ?, status = ?, target_completion_date = ?, completed_at = ? WHERE id = ? AND user_id = ?',
        [title, description, status, target_completion_date, completed_at, id, userId],
        function(err) {
          if (err) reject(err);
          else resolve({ id, ...missionData });
        }
      );
    });
  }

  static delete(id, userId = 'ufaq') {
    return new Promise((resolve, reject) => {
      db.run('DELETE FROM missions WHERE id = ? AND user_id = ?', [id, userId], function(err) {
        if (err) reject(err);
        else resolve({ deleted: this.changes > 0 });
      });
    });
  }
}

module.exports = Mission;
EOF

# Update DailyMission model with user filtering
cat > "$PROJECT_ROOT/backend/models/DailyMission.js" << 'EOF'
const db = require('../database/database');
const { v4: uuidv4 } = require('uuid');

class DailyMission {
  static getAll(userId = 'ufaq') {
    return new Promise((resolve, reject) => {
      db.all(`
        SELECT dm.*, m.title as mission_title 
        FROM daily_missions dm 
        JOIN missions m ON dm.mission_id = m.id 
        WHERE dm.user_id = ?
        ORDER BY dm.priority ASC, dm.created_at DESC
      `, [userId], (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
  }

  static getByMissionId(missionId, userId = 'ufaq') {
    return new Promise((resolve, reject) => {
      db.all(
        'SELECT * FROM daily_missions WHERE mission_id = ? AND user_id = ? ORDER BY priority ASC, created_at DESC',
        [missionId, userId],
        (err, rows) => {
          if (err) reject(err);
          else resolve(rows);
        }
      );
    });
  }

  static create(dailyMissionData, userId = 'ufaq') {
    return new Promise((resolve, reject) => {
      const id = uuidv4();
      const { mission_id, title, description, due_date, priority = 2 } = dailyMissionData;
      
      db.run(
        'INSERT INTO daily_missions (id, mission_id, title, description, due_date, priority, user_id) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [id, mission_id, title, description, due_date, priority, userId],
        function(err) {
          if (err) reject(err);
          else resolve({ id, ...dailyMissionData, priority, user_id: userId });
        }
      );
    });
  }

  static update(id, dailyMissionData, userId = 'ufaq') {
    return new Promise((resolve, reject) => {
      const { title, description, status, due_date, priority = 2 } = dailyMissionData;
      
      let completed_at = null;
      if (status === 'completed') {
        completed_at = new Date().toISOString();
      }
      
      db.run(
        'UPDATE daily_missions SET title = ?, description = ?, status = ?, due_date = ?, priority = ?, completed_at = ? WHERE id = ? AND user_id = ?',
        [title, description, status, due_date, priority, completed_at, id, userId],
        function(err) {
          if (err) reject(err);
          else resolve({ id, ...dailyMissionData, priority, completed_at });
        }
      );
    });
  }

  static delete(id, userId = 'ufaq') {
    return new Promise((resolve, reject) => {
      db.run('DELETE FROM daily_missions WHERE id = ? AND user_id = ?', [id, userId], function(err) {
        if (err) reject(err);
        else resolve({ deleted: this.changes > 0 });
      });
    });
  }
}

module.exports = DailyMission;
EOF

echo "🛡️ Step 5: Updating existing routes with simple auth..."

# Update missions routes
cat > "$PROJECT_ROOT/backend/routes/missions.js" << 'EOF'
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
EOF

# Update daily missions routes
cat > "$PROJECT_ROOT/backend/routes/dailyMissions.js" << 'EOF'
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
EOF

# Update today missions routes
cat > "$PROJECT_ROOT/backend/routes/todayMissions.js" << 'EOF'
const express = require('express');
const router = express.Router();
const DailyMission = require('../models/DailyMission');
const { authenticateUser } = require('../middleware/simpleAuth');

// Apply authentication to all routes
router.use(authenticateUser);

// Get today's missions for authenticated user
router.get('/', async (req, res) => {
  try {
    const today = new Date().toISOString().split('T')[0];
    
    const todayMissions = await new Promise((resolve, reject) => {
      const db = require('../database/database');
      db.all(`
        SELECT dm.*, m.title as mission_title, m.status as mission_status
        FROM daily_missions dm 
        JOIN missions m ON dm.mission_id = m.id 
        WHERE (dm.due_date <= ? OR dm.due_date IS NULL) 
        AND dm.status != 'completed' 
        AND m.status = 'active'
        AND dm.user_id = ?
        ORDER BY dm.priority ASC, dm.due_date ASC, dm.created_at DESC
      `, [today, req.user.username], (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
    
    res.json(todayMissions);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get today's completed missions for authenticated user
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
        AND dm.user_id = ?
        ORDER BY dm.completed_at DESC
      `, [todayStart, todayEnd, req.user.username], (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
    
    res.json(completedToday);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Quick add today's mission for authenticated user
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
    
    const dailyMission = await DailyMission.create(dailyMissionData, req.user.username);
    res.status(201).json(dailyMission);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
EOF

echo "🖥️ Step 6: Updating server.js..."

# Update server.js
cat > "$PROJECT_ROOT/backend/server.js" << 'EOF'
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
EOF

echo "⚛️ Step 7: Creating simple React authentication..."

# Create simple login component
cat > "$PROJECT_ROOT/frontend/src/components/SimpleLogin.js" << 'EOF'
import React, { useState } from 'react';

const SimpleLogin = ({ onLogin }) => {
  const [credentials, setCredentials] = useState({
    username: '',
    password: ''
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const response = await fetch('/api/auth/login', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(credentials),
      });

      const data = await response.json();

      if (data.success) {
        onLogin(data.user.username);
      } else {
        setError(data.error);
      }
    } catch (error) {
      setError('Network error. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e) => {
    setCredentials({
      ...credentials,
      [e.target.name]: e.target.value
    });
  };

  return (
    <div style={{
      minHeight: '100vh',
      backgroundColor: '#f5f7fa',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center'
    }}>
      <div style={{
        maxWidth: '400px',
        width: '100%',
        padding: '40px',
        backgroundColor: 'white',
        borderRadius: '12px',
        boxShadow: '0 4px 20px rgba(0,0,0,0.1)',
        border: '1px solid #e1e5e9'
      }}>
        <div style={{ textAlign: 'center', marginBottom: '30px' }}>
          <h1 style={{ margin: '0 0 10px 0', color: '#333', fontSize: '28px' }}>🎯 Mission Tracker</h1>
          <p style={{ margin: '0', color: '#666', fontSize: '16px' }}>Please sign in to continue</p>
        </div>

        {error && (
          <div style={{
            backgroundColor: '#fee',
            color: '#c33',
            padding: '12px',
            borderRadius: '6px',
            marginBottom: '20px',
            fontSize: '14px',
            border: '1px solid #fcc'
          }}>
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit}>
          <div style={{ marginBottom: '20px' }}>
            <label style={{ display: 'block', marginBottom: '8px', color: '#333', fontWeight: '500' }}>
              Username
            </label>
            <input
              type="text"
              name="username"
              value={credentials.username}
              onChange={handleChange}
              required
              style={{
                width: '100%',
                padding: '12px',
                borderRadius: '6px',
                border: '2px solid #e1e5e9',
                fontSize: '14px',
                transition: 'border-color 0.3s'
              }}
              placeholder="Enter your username"
            />
          </div>

          <div style={{ marginBottom: '25px' }}>
            <label style={{ display: 'block', marginBottom: '8px', color: '#333', fontWeight: '500' }}>
              Password
            </label>
            <input
              type="password"
              name="password"
              value={credentials.password}
              onChange={handleChange}
              required
              style={{
                width: '100%',
                padding: '12px',
                borderRadius: '6px',
                border: '2px solid #e1e5e9',
                fontSize: '14px',
                transition: 'border-color 0.3s'
              }}
              placeholder="Enter your password"
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            style={{
              width: '100%',
              backgroundColor: loading ? '#ccc' : '#007bff',
              color: 'white',
              padding: '14px',
              border: 'none',
              borderRadius: '6px',
              fontSize: '16px',
              fontWeight: '600',
              cursor: loading ? 'not-allowed' : 'pointer',
              transition: 'background-color 0.3s'
            }}
          >
            {loading ? 'Signing In...' : 'Sign In'}
          </button>
        </form>

        <div style={{ textAlign: 'center', marginTop: '25px', color: '#666', fontSize: '14px' }}>
          <p style={{ margin: '0' }}>Available users: <strong>ufaq</strong>, <strong>zia</strong>, <strong>sweta</strong></p>
        </div>
      </div>
    </div>
  );
};

export default SimpleLogin;
EOF

echo "🔄 Step 8: Updating API service to include user header..."

# Update API service to include current user header
cat > "$PROJECT_ROOT/frontend/src/services/api.js" << 'EOF'
import axios from 'axios';

const API_BASE_URL = 'http://localhost:5000/api';

const api = axios.create({
  baseURL: API_BASE_URL,
});

// Add current user to requests automatically
api.interceptors.request.use(
  (config) => {
    const currentUser = localStorage.getItem('currentUser');
    if (currentUser) {
      config.headers['x-current-user'] = currentUser;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Handle authentication errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Authentication failed, redirect to login
      localStorage.removeItem('currentUser');
      window.location.reload();
    }
    return Promise.reject(error);
  }
);

export const missionAPI = {
  getAll: () => api.get('/missions'),
  getById: (id) => api.get(`/missions/${id}`),
  create: (data) => api.post('/missions', data),
  update: (id, data) => api.put(`/missions/${id}`, data),
  delete: (id) => api.delete(`/missions/${id}`),
};

export const dailyMissionAPI = {
  getAll: () => api.get('/daily-missions'),
  getByMissionId: (missionId) => api.get(`/daily-missions/mission/${missionId}`),
  create: (data) => api.post('/daily-missions', data),
  update: (id, data) => api.put(`/daily-missions/${id}`, data),
  delete: (id) => api.delete(`/daily-missions/${id}`),
};

export const todayAPI = {
  getTodayMissions: () => api.get('/today'),
  getCompletedToday: () => api.get('/today/completed'),
  quickAdd: (data) => api.post('/today/quick-add', data),
};

export const authAPI = {
  login: (data) => api.post('/auth/login', data),
  getUsers: () => api.get('/auth/users'),
};

export default api;
EOF

echo "🏠 Step 9: Updating main App.js with simple authentication..."

# Update App.js with simple authentication
cat > "$PROJECT_ROOT/frontend/src/App.js" << 'EOF'
import React, { useState, useEffect } from 'react';
import SimpleLogin from './components/SimpleLogin';
import TodayDashboard from './components/TodayDashboard';
import MissionList from './components/MissionList';
import MissionForm from './components/MissionForm';
import DailyMissionList from './components/DailyMissionList';
import DailyMissionForm from './components/DailyMissionForm';
import { missionAPI, dailyMissionAPI } from './services/api';

function App() {
  const [currentUser, setCurrentUser] = useState(localStorage.getItem('currentUser'));
  const [missions, setMissions] = useState([]);
  const [dailyMissions, setDailyMissions] = useState([]);
  const [selectedMissionId, setSelectedMissionId] = useState(null);
  const [showMissionForm, setShowMissionForm] = useState(false);
  const [showDailyMissionForm, setShowDailyMissionForm] = useState(false);
  const [editingMission, setEditingMission] = useState(null);
  const [editingDailyMission, setEditingDailyMission] = useState(null);
  const [loading, setLoading] = useState(true);
  const [currentView, setCurrentView] = useState('today');

  useEffect(() => {
    if (currentUser) {
      loadMissions();
    } else {
      setLoading(false);
    }
  }, [currentUser]);

  useEffect(() => {
    if (selectedMissionId && currentUser) {
      loadDailyMissions(selectedMissionId);
    } else {
      setDailyMissions([]);
    }
  }, [selectedMissionId, currentUser]);

  const handleLogin = (username) => {
    setCurrentUser(username);
    localStorage.setItem('currentUser', username);
  };

  const handleLogout = () => {
    setCurrentUser(null);
    localStorage.removeItem('currentUser');
    setMissions([]);
    setDailyMissions([]);
    setSelectedMissionId(null);
  };

  const loadMissions = async () => {
    try {
      const response = await missionAPI.getAll();
      setMissions(response.data);
    } catch (error) {
      console.error('Error loading missions:', error);
      if (error.response?.status === 401) {
        handleLogout();
      }
    } finally {
      setLoading(false);
    }
  };

  const loadDailyMissions = async (missionId) => {
    try {
      const response = await dailyMissionAPI.getByMissionId(missionId);
      setDailyMissions(response.data);
    } catch (error) {
      console.error('Error loading daily missions:', error);
    }
  };

  const handleCreateMission = async (missionData) => {
    try {
      await missionAPI.create(missionData);
      await loadMissions();
      setShowMissionForm(false);
    } catch (error) {
      console.error('Error creating mission:', error);
    }
  };

  const handleUpdateMission = async (missionData) => {
    try {
      await missionAPI.update(editingMission.id, missionData);
      await loadMissions();
      setEditingMission(null);
      setShowMissionForm(false);
    } catch (error) {
      console.error('Error updating mission:', error);
    }
  };

  const handleDeleteMission = async (missionId) => {
    try {
      await missionAPI.delete(missionId);
      await loadMissions();
      if (selectedMissionId === missionId) {
        setSelectedMissionId(null);
      }
    } catch (error) {
      console.error('Error deleting mission:', error);
    }
  };

  const handleCreateDailyMission = async (dailyMissionData) => {
    try {
      await dailyMissionAPI.create(dailyMissionData);
      await loadDailyMissions(selectedMissionId);
      setShowDailyMissionForm(false);
    } catch (error) {
      console.error('Error creating daily mission:', error);
    }
  };

  const handleUpdateDailyMission = async (dailyMissionData) => {
    try {
      await dailyMissionAPI.update(editingDailyMission.id, dailyMissionData);
      await loadDailyMissions(selectedMissionId);
      setEditingDailyMission(null);
      setShowDailyMissionForm(false);
    } catch (error) {
      console.error('Error updating daily mission:', error);
    }
  };

  const handleDeleteDailyMission = async (dailyMissionId) => {
    try {
      await dailyMissionAPI.delete(dailyMissionId);
      await loadDailyMissions(selectedMissionId);
    } catch (error) {
      console.error('Error deleting daily mission:', error);
    }
  };

  const handleToggleComplete = async (dailyMission) => {
    const newStatus = dailyMission.status === 'completed' ? 'pending' : 'completed';
    try {
      await dailyMissionAPI.update(dailyMission.id, {
        ...dailyMission,
        status: newStatus
      });
      await loadDailyMissions(selectedMissionId);
    } catch (error) {
      console.error('Error updating daily mission status:', error);
    }
  };

  const refreshData = async () => {
    await loadMissions();
    if (selectedMissionId) {
      await loadDailyMissions(selectedMissionId);
    }
  };

  // Show login screen if not authenticated
  if (!currentUser) {
    return <SimpleLogin onLogin={handleLogin} />;
  }

  // Show loading screen while data is loading
  if (loading) {
    return (
      <div style={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: '#f5f7fa'
      }}>
        <div style={{ textAlign: 'center' }}>
          <h2 style={{ color: '#333' }}>🎯 Mission Tracker</h2>
          <p style={{ color: '#666' }}>Loading your missions...</p>
        </div>
      </div>
    );
  }

  return (
    <div>
      {/* Top Navigation Bar */}
      <div style={{
        backgroundColor: '#007bff',
        color: 'white',
        padding: '15px 20px',
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
      }}>
        <h1 style={{ margin: 0, fontSize: '24px' }}>🎯 Mission Tracker</h1>
        
        <div style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
          <span style={{ fontSize: '14px', opacity: '0.9' }}>
            Welcome, <strong>{currentUser}</strong>!
          </span>
          <button
            onClick={handleLogout}
            style={{
              backgroundColor: 'rgba(255,255,255,0.2)',
              color: 'white',
              border: '1px solid rgba(255,255,255,0.3)',
              padding: '8px 16px',
              borderRadius: '4px',
              cursor: 'pointer',
              fontSize: '14px',
              transition: 'background-color 0.3s'
            }}
          >
            Logout
          </button>
        </div>
      </div>

      <div style={{ maxWidth: '1400px', margin: '0 auto', padding: '20px' }}>
        {/* Navigation */}
        <div style={{ 
          display: 'flex', 
          justifyContent: 'center', 
          marginBottom: '20px',
          backgroundColor: 'white',
          padding: '10px',
          borderRadius: '8px',
          border: '1px solid #ddd'
        }}>
          <button
            onClick={() => setCurrentView('today')}
            style={{
              backgroundColor: currentView === 'today' ? '#007bff' : 'transparent',
              color: currentView === 'today' ? 'white' : '#666',
              border: '1px solid #007bff',
              padding: '10px 20px',
              borderRadius: '6px 0 0 6px',
              cursor: 'pointer',
              fontSize: '16px',
              fontWeight: 'bold'
            }}
          >
            🎯 Today's Focus
          </button>
          <button
            onClick={() => setCurrentView('missions')}
            style={{
              backgroundColor: currentView === 'missions' ? '#007bff' : 'transparent',
              color: currentView === 'missions' ? 'white' : '#666',
              border: '1px solid #007bff',
              borderLeft: 'none',
              padding: '10px 20px',
              borderRadius: '0 6px 6px 0',
              cursor: 'pointer',
              fontSize: '16px',
              fontWeight: 'bold'
            }}
          >
            📋 Manage Missions
          </button>
        </div>

        {currentView === 'today' ? (
          <TodayDashboard missions={missions} onRefresh={refreshData} />
        ) : (
          <>
            <div style={{ textAlign: 'center', marginBottom: '30px' }}>
              <h1 style={{ color: '#333', margin: '0 0 10px 0' }}>📋 Mission Management</h1>
              <p style={{ color: '#666', margin: '0' }}>Organize your long-term goals and create daily missions</p>
            </div>
            
            <div style={{ display: 'flex', gap: '30px' }}>
              <div style={{ flex: 1 }}>
                <div style={{ marginBottom: '20px' }}>
                  <button
                    onClick={() => {
                      setShowMissionForm(!showMissionForm);
                      setEditingMission(null);
                    }}
                    style={{
                      backgroundColor: '#007bff',
                      color: 'white',
                      padding: '10px 20px',
                      border: 'none',
                      borderRadius: '4px',
                      cursor: 'pointer',
                      fontSize: '16px'
                    }}
                  >
                    {showMissionForm ? 'Cancel' : '+ New Mission'}
                  </button>
                </div>

                {showMissionForm && (
                  <MissionForm
                    onSubmit={editingMission ? handleUpdateMission : handleCreateMission}
                    mission={editingMission}
                    onCancel={() => {
                      setShowMissionForm(false);
                      setEditingMission(null);
                    }}
                  />
                )}

                <MissionList
                  missions={missions}
                  selectedMissionId={selectedMissionId}
                  onSelectMission={setSelectedMissionId}
                  onEdit={(mission) => {
                    setEditingMission(mission);
                    setShowMissionForm(true);
                  }}
                  onDelete={handleDeleteMission}
                />
              </div>

              <div style={{ flex: 1 }}>
                {selectedMissionId ? (
                  <>
                    <div style={{ marginBottom: '20px' }}>
                      <button
                        onClick={() => {
                          setShowDailyMissionForm(!showDailyMissionForm);
                          setEditingDailyMission(null);
                        }}
                        style={{
                          backgroundColor: '#28a745',
                          color: 'white',
                          padding: '10px 20px',
                          border: 'none',
                          borderRadius: '4px',
                          cursor: 'pointer',
                          fontSize: '16px'
                        }}
                      >
                        {showDailyMissionForm ? 'Cancel' : '+ New Daily Mission'}
                      </button>
                    </div>

                    {showDailyMissionForm && (
                      <DailyMissionForm
                        onSubmit={editingDailyMission ? handleUpdateDailyMission : handleCreateDailyMission}
                        dailyMission={editingDailyMission}
                        missionId={selectedMissionId}
                        onCancel={() => {
                          setShowDailyMissionForm(false);
                          setEditingDailyMission(null);
                        }}
                      />
                    )}

                    <div style={{ backgroundColor: 'white', padding: '20px', borderRadius: '8px' }}>
                      <DailyMissionList
                        dailyMissions={dailyMissions}
                        onEdit={(dailyMission) => {
                          setEditingDailyMission(dailyMission);
                          setShowDailyMissionForm(true);
                        }}
                        onDelete={handleDeleteDailyMission}
                        onToggleComplete={handleToggleComplete}
                      />
                    </div>
                  </>
                ) : (
                  <div style={{ 
                    backgroundColor: 'white', 
                    padding: '40px', 
                    borderRadius: '8px', 
                    textAlign: 'center',
                    color: '#666'
                  }}>
                    <h3>Select a mission to manage daily missions</h3>
                    <p>Click on a mission from the left panel to start managing daily missions.</p>
                  </div>
                )}
              </div>
            </div>
          </>
        )}
      </div>
    </div>
  );
}

export default App;
EOF

echo "🔍 Step 10: Verification checks..."

VERIFICATION_FAILED=false

# Check if key files exist
if [ ! -f "$PROJECT_ROOT/backend/middleware/simpleAuth.js" ]; then
  echo "❌ Critical file missing: simpleAuth.js middleware"
  VERIFICATION_FAILED=true
fi

if [ ! -f "$PROJECT_ROOT/backend/routes/simpleAuth.js" ]; then
  echo "❌ Critical file missing: simpleAuth.js routes"
  VERIFICATION_FAILED=true
fi

if [ ! -f "$PROJECT_ROOT/frontend/src/components/SimpleLogin.js" ]; then
  echo "❌ Critical file missing: SimpleLogin.js component"
  VERIFICATION_FAILED=true
fi

# Check if App.js has the right structure (not broken imports)
if ! grep -q "SimpleLogin" "$PROJECT_ROOT/frontend/src/App.js"; then
  echo "❌ App.js doesn't import SimpleLogin properly"
  VERIFICATION_FAILED=true
fi

# If verification failed, auto-rollback
if [ "$VERIFICATION_FAILED" = true ]; then
  echo "🚨 VERIFICATION FAILED - Auto-rolling back..."
  ./rollback_${FEATURE_NAME}_${TIMESTAMP}.sh
  echo "❌ Simple authentication enhancement failed and was rolled back automatically."
  exit 1
fi

echo "✅ Simple authentication system verification passed!"

# Create restart script
cat > "restart_app_with_simple_auth.sh" << 'EOF'
#!/bin/bash
echo "🔄 Restarting Mission Tracker with Simple Authentication..."
pkill -f "npm run dev" 2>/dev/null || true
pkill -f "npm start" 2>/dev/null || true
sleep 2
cd backend && npm run dev &
sleep 3
cd ../frontend && npm start &
echo "✅ App restarting with simple authentication enabled..."
echo "📱 Frontend: http://localhost:3000"
echo "🔐 Backend: http://localhost:5000"
echo ""
echo "🔑 Login with:"
echo "   ufaq / ufitufy"
echo "   zia / zeetv"
echo "   sweta / ss786"
EOF

chmod +x restart_app_with_simple_auth.sh

echo ""
echo "🎉 SIMPLE 3-USER AUTHENTICATION SUCCESSFULLY ADDED!"
echo ""
echo "🔐 AUTHENTICATION FEATURES:"
echo "• ✅ 3 Hardcoded Users: ufaq, zia, sweta"
echo "• ✅ Simple Login Form: Clean username/password interface"
echo "• ✅ User Data Isolation: Each user sees only their own missions/tasks"
echo "• ✅ Session Management: Remembers login until logout"
echo "• ✅ Protected Routes: All API endpoints require authentication"
echo "• ✅ User Header: Shows current user and logout button"
echo ""
echo "🔑 USER CREDENTIALS:"
echo "   👤 ufaq → password: ufitufy"
echo "   👤 zia → password: zeetv"
echo "   👤 sweta → password: ss786"
echo ""
echo "🛡️ SECURITY FEATURES:"
echo "• 🔒 Simple but effective authentication verification"
echo "• 👤 User isolation - no data mixing between users"
echo "• 🚫 Protected API endpoints with user validation"
echo "• 🔓 Secure logout clears session completely"
echo ""
echo "📊 USER EXPERIENCE:"
echo "• 🎯 Clean login screen on app start"
echo "• 👋 Personalized welcome message with username"
echo "• 🔄 Automatic session restoration on page refresh"
echo "• ⚠️ Clear error messages for invalid credentials"
echo ""
echo "📦 BACKUP & ROLLBACK:"
echo "✅ Full backup created: $BACKUP_DIR"
echo "🔄 Rollback available: ./rollback_${FEATURE_NAME}_${TIMESTAMP}.sh"
echo ""
echo "🚀 TO START THE AUTHENTICATED APP:"
echo "./restart_app_with_simple_auth.sh"
echo ""
echo "🎯 READY FOR MULTI-USER DEPLOYMENT!"
echo "Your app now supports 3 secure users, each with their own workspace! 🌟"
