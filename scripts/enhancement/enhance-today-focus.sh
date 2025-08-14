#!/bin/bash

echo "🎯 Enhancing Mission Tracker to focus on TODAY'S GOALS..."
echo "Creating backup of existing files..."

# Create backup directory
mkdir -p backup
cp -r frontend/src backup/frontend-src-backup
cp -r backend backup/backend-backup

# Navigate to project root
cd mission-tracker

echo "📅 Adding Today's Focus functionality..."

# Update backend to add today-focused endpoints
cat > backend/routes/todayMissions.js << 'EOF'
const express = require('express');
const router = express.Router();
const DailyMission = require('../models/DailyMission');

// Get today's missions (due today or overdue)
router.get('/', async (req, res) => {
  try {
    const today = new Date().toISOString().split('T')[0]; // YYYY-MM-DD format
    
    const todayMissions = await new Promise((resolve, reject) => {
      const db = require('../database/database');
      db.all(`
        SELECT dm.*, m.title as mission_title, m.status as mission_status
        FROM daily_missions dm 
        JOIN missions m ON dm.mission_id = m.id 
        WHERE (dm.due_date <= ? OR dm.due_date IS NULL) 
        AND dm.status != 'completed' 
        AND m.status = 'active'
        ORDER BY dm.due_date ASC, dm.created_at DESC
      `, [today], (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
    
    res.json(todayMissions);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get today's completed missions
router.get('/completed', async (req, res) => {
  try {
    const today = new Date().toISOString().split('T')[0];
    const todayStart = today + ' 00:00:00';
    const todayEnd = today + ' 23:59:59';
    
    const completedToday = await new Promise((resolve, reject) => {
      const db = require('../database/database');
      db.all(`
        SELECT dm.*, m.title as mission_title
        FROM daily_missions dm 
        JOIN missions m ON dm.mission_id = m.id 
        WHERE dm.status = 'completed' 
        AND dm.completed_at BETWEEN ? AND ?
        ORDER BY dm.completed_at DESC
      `, [todayStart, todayEnd], (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
    
    res.json(completedToday);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Quick add today's mission
router.post('/quick-add', async (req, res) => {
  try {
    const { title, mission_id } = req.body;
    const today = new Date().toISOString().split('T')[0];
    
    const dailyMissionData = {
      mission_id: mission_id,
      title: title,
      description: '',
      due_date: today
    };
    
    const dailyMission = await DailyMission.create(dailyMissionData);
    res.status(201).json(dailyMission);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
EOF

# Update server.js to include today's routes
cat > backend/server.js << 'EOF'
const express = require('express');
const cors = require('cors');
require('./database/database'); // Initialize database

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/missions', require('./routes/missions'));
app.use('/api/daily-missions', require('./routes/dailyMissions'));
app.use('/api/today', require('./routes/todayMissions'));

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'Server is running!' });
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
EOF

# Create Today's Dashboard Component
cat > frontend/src/components/TodayDashboard.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { dailyMissionAPI } from '../services/api';

const TodayDashboard = ({ missions, onRefresh }) => {
  const [todayMissions, setTodayMissions] = useState([]);
  const [completedToday, setCompletedToday] = useState([]);
  const [quickAddTitle, setQuickAddTitle] = useState('');
  const [selectedMissionId, setSelectedMissionId] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadTodayData();
  }, []);

  const loadTodayData = async () => {
    try {
      const [todayResponse, completedResponse] = await Promise.all([
        fetch('/api/today'),
        fetch('/api/today/completed')
      ]);
      
      const todayData = await todayResponse.json();
      const completedData = await completedResponse.json();
      
      setTodayMissions(todayData);
      setCompletedToday(completedData);
    } catch (error) {
      console.error('Error loading today\'s data:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleQuickAdd = async (e) => {
    e.preventDefault();
    if (!quickAddTitle.trim() || !selectedMissionId) return;

    try {
      await fetch('/api/today/quick-add', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: quickAddTitle,
          mission_id: selectedMissionId
        })
      });
      
      setQuickAddTitle('');
      await loadTodayData();
      onRefresh();
    } catch (error) {
      console.error('Error adding quick mission:', error);
    }
  };

  const handleToggleComplete = async (mission) => {
    const newStatus = mission.status === 'completed' ? 'pending' : 'completed';
    try {
      await dailyMissionAPI.update(mission.id, {
        ...mission,
        status: newStatus
      });
      await loadTodayData();
      onRefresh();
    } catch (error) {
      console.error('Error updating mission:', error);
    }
  };

  const getTodayDate = () => {
    return new Date().toLocaleDateString('en-US', { 
      weekday: 'long', 
      year: 'numeric', 
      month: 'long', 
      day: 'numeric' 
    });
  };

  const getProgressPercentage = () => {
    const total = todayMissions.length + completedToday.length;
    if (total === 0) return 0;
    return Math.round((completedToday.length / total) * 100);
  };

  if (loading) {
    return <div style={{ padding: '20px' }}>Loading today's goals...</div>;
  }

  return (
    <div style={{ marginBottom: '30px' }}>
      {/* Header */}
      <div style={{ 
        backgroundColor: '#007bff', 
        color: 'white', 
        padding: '20px', 
        borderRadius: '12px',
        marginBottom: '20px',
        textAlign: 'center'
      }}>
        <h1 style={{ margin: '0 0 10px 0', fontSize: '28px' }}>🎯 Today's Focus</h1>
        <p style={{ margin: '0 0 15px 0', fontSize: '16px', opacity: '0.9' }}>{getTodayDate()}</p>
        
        {/* Progress Bar */}
        <div style={{ backgroundColor: 'rgba(255,255,255,0.2)', borderRadius: '10px', height: '8px', marginBottom: '10px' }}>
          <div style={{ 
            backgroundColor: '#28a745', 
            height: '100%', 
            borderRadius: '10px',
            width: `${getProgressPercentage()}%`,
            transition: 'width 0.3s ease'
          }}></div>
        </div>
        <p style={{ margin: '0', fontSize: '14px', opacity: '0.9' }}>
          {completedToday.length} completed • {todayMissions.length} remaining • {getProgressPercentage()}% done
        </p>
      </div>

      {/* Quick Add */}
      <div style={{ 
        backgroundColor: 'white', 
        padding: '15px', 
        borderRadius: '8px', 
        marginBottom: '20px',
        border: '1px solid #ddd'
      }}>
        <h3 style={{ margin: '0 0 15px 0', color: '#333' }}>⚡ Quick Add Today's Goal</h3>
        <form onSubmit={handleQuickAdd} style={{ display: 'flex', gap: '10px', alignItems: 'end' }}>
          <div style={{ flex: 1 }}>
            <input
              type="text"
              placeholder="What do you want to accomplish today?"
              value={quickAddTitle}
              onChange={(e) => setQuickAddTitle(e.target.value)}
              style={{
                width: '100%',
                padding: '10px',
                borderRadius: '6px',
                border: '1px solid #ddd',
                fontSize: '14px'
              }}
            />
          </div>
          <div style={{ minWidth: '150px' }}>
            <select
              value={selectedMissionId}
              onChange={(e) => setSelectedMissionId(e.target.value)}
              style={{
                width: '100%',
                padding: '10px',
                borderRadius: '6px',
                border: '1px solid #ddd',
                fontSize: '14px'
              }}
            >
              <option value="">Select Mission</option>
              {missions.filter(m => m.status === 'active').map(mission => (
                <option key={mission.id} value={mission.id}>{mission.title}</option>
              ))}
            </select>
          </div>
          <button
            type="submit"
            disabled={!quickAddTitle.trim() || !selectedMissionId}
            style={{
              backgroundColor: '#28a745',
              color: 'white',
              border: 'none',
              padding: '10px 20px',
              borderRadius: '6px',
              cursor: 'pointer',
              fontSize: '14px',
              opacity: (!quickAddTitle.trim() || !selectedMissionId) ? 0.5 : 1
            }}
          >
            Add Goal
          </button>
        </form>
      </div>

      <div style={{ display: 'flex', gap: '20px' }}>
        {/* Today's Pending Goals */}
        <div style={{ flex: 1 }}>
          <div style={{ 
            backgroundColor: 'white', 
            padding: '20px', 
            borderRadius: '8px',
            border: '1px solid #ddd',
            minHeight: '200px'
          }}>
            <h3 style={{ margin: '0 0 15px 0', color: '#dc3545', display: 'flex', alignItems: 'center', gap: '8px' }}>
              🎯 Focus Now ({todayMissions.length})
            </h3>
            
            {todayMissions.length === 0 ? (
              <div style={{ textAlign: 'center', color: '#666', padding: '40px 20px' }}>
                <p style={{ fontSize: '18px', margin: '0 0 10px 0' }}>🎉 All caught up!</p>
                <p style={{ margin: '0' }}>No pending goals for today. Add some above!</p>
              </div>
            ) : (
              todayMissions.map(mission => (
                <div
                  key={mission.id}
                  style={{
                    backgroundColor: '#fff5f5',
                    border: '1px solid #fecaca',
                    padding: '12px',
                    marginBottom: '10px',
                    borderRadius: '6px',
                    borderLeft: '4px solid #dc3545'
                  }}
                >
                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                    <input
                      type="checkbox"
                      checked={false}
                      onChange={() => handleToggleComplete(mission)}
                      style={{ transform: 'scale(1.3)' }}
                    />
                    <div style={{ flex: 1 }}>
                      <h4 style={{ margin: '0 0 5px 0', color: '#333' }}>{mission.title}</h4>
                      <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
                        <span style={{ 
                          fontSize: '12px', 
                          color: '#666',
                          backgroundColor: '#e3f2fd',
                          padding: '2px 6px',
                          borderRadius: '3px'
                        }}>
                          📋 {mission.mission_title}
                        </span>
                        {mission.due_date && (
                          <span style={{ 
                            fontSize: '12px', 
                            color: new Date(mission.due_date) < new Date() ? '#dc3545' : '#666' 
                          }}>
                            {new Date(mission.due_date) < new Date() ? '⚠️ Overdue' : '📅 Due today'}
                          </span>
                        )}
                      </div>
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Today's Completed Goals */}
        <div style={{ flex: 1 }}>
          <div style={{ 
            backgroundColor: 'white', 
            padding: '20px', 
            borderRadius: '8px',
            border: '1px solid #ddd',
            minHeight: '200px'
          }}>
            <h3 style={{ margin: '0 0 15px 0', color: '#28a745', display: 'flex', alignItems: 'center', gap: '8px' }}>
              ✅ Completed Today ({completedToday.length})
            </h3>
            
            {completedToday.length === 0 ? (
              <div style={{ textAlign: 'center', color: '#666', padding: '40px 20px' }}>
                <p style={{ margin: '0' }}>No goals completed yet today. You got this! 💪</p>
              </div>
            ) : (
              completedToday.map(mission => (
                <div
                  key={mission.id}
                  style={{
                    backgroundColor: '#f0fff4',
                    border: '1px solid #bbf7d0',
                    padding: '12px',
                    marginBottom: '10px',
                    borderRadius: '6px',
                    borderLeft: '4px solid #28a745',
                    opacity: '0.8'
                  }}
                >
                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                    <input
                      type="checkbox"
                      checked={true}
                      onChange={() => handleToggleComplete(mission)}
                      style={{ transform: 'scale(1.3)' }}
                    />
                    <div style={{ flex: 1 }}>
                      <h4 style={{ 
                        margin: '0 0 5px 0', 
                        color: '#333',
                        textDecoration: 'line-through'
                      }}>
                        {mission.title}
                      </h4>
                      <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
                        <span style={{ 
                          fontSize: '12px', 
                          color: '#666',
                          backgroundColor: '#e3f2fd',
                          padding: '2px 6px',
                          borderRadius: '3px'
                        }}>
                          📋 {mission.mission_title}
                        </span>
                        <span style={{ fontSize: '12px', color: '#28a745' }}>
                          ✅ {new Date(mission.completed_at).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})}
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default TodayDashboard;
EOF

# Update the API service to include today's endpoints
cat > frontend/src/services/api.js << 'EOF'
import axios from 'axios';

const API_BASE_URL = 'http://localhost:5000/api';

const api = axios.create({
  baseURL: API_BASE_URL,
});

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

export default api;
EOF

# Update the main App component to be today-focused
cat > frontend/src/App.js << 'EOF'
import React, { useState, useEffect } from 'react';
import TodayDashboard from './components/TodayDashboard';
import MissionList from './components/MissionList';
import MissionForm from './components/MissionForm';
import DailyMissionList from './components/DailyMissionList';
import DailyMissionForm from './components/DailyMissionForm';
import { missionAPI, dailyMissionAPI } from './services/api';

function App() {
  const [missions, setMissions] = useState([]);
  const [dailyMissions, setDailyMissions] = useState([]);
  const [selectedMissionId, setSelectedMissionId] = useState(null);
  const [showMissionForm, setShowMissionForm] = useState(false);
  const [showDailyMissionForm, setShowDailyMissionForm] = useState(false);
  const [editingMission, setEditingMission] = useState(null);
  const [editingDailyMission, setEditingDailyMission] = useState(null);
  const [loading, setLoading] = useState(true);
  const [currentView, setCurrentView] = useState('today'); // 'today' or 'missions'

  useEffect(() => {
    loadMissions();
  }, []);

  useEffect(() => {
    if (selectedMissionId) {
      loadDailyMissions(selectedMissionId);
    } else {
      setDailyMissions([]);
    }
  }, [selectedMissionId]);

  const loadMissions = async () => {
    try {
      const response = await missionAPI.getAll();
      setMissions(response.data);
    } catch (error) {
      console.error('Error loading missions:', error);
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

  if (loading) {
    return <div style={{ padding: '20px' }}>Loading...</div>;
  }

  return (
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
        /* TODAY'S FOCUS VIEW - This is the main view */
        <TodayDashboard missions={missions} onRefresh={refreshData} />
      ) : (
        /* MISSION MANAGEMENT VIEW - Secondary view */
        <>
          <div style={{ textAlign: 'center', marginBottom: '30px' }}>
            <h1 style={{ color: '#333', margin: '0 0 10px 0' }}>📋 Mission Management</h1>
            <p style={{ color: '#666', margin: '0' }}>Organize your long-term goals and create daily missions</p>
          </div>
          
          <div style={{ display: 'flex', gap: '30px' }}>
            {/* Left Panel - Missions */}
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

            {/* Right Panel - Daily Missions */}
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
  );
}

export default App;
EOF

echo "🔄 Restarting servers to apply changes..."

# Kill existing processes (if running)
pkill -f "npm run dev"
pkill -f "npm start"

# Install any new dependencies (if needed)
cd backend
npm install > /dev/null 2>&1

cd ../frontend  
npm install > /dev/null 2>&1

echo ""
echo "✅ Enhancement Complete!"
echo ""
echo "🎯 YOUR APP IS NOW TODAY-FOCUSED!"
echo ""
echo "Key Changes Made:"
echo "• 📅 Today's Focus Dashboard - Main screen shows today's goals"
echo "• ⚡ Quick Add - Fast way to add goals for today"
echo "• 📊 Progress Tracking - See completion percentage for today"
echo "• 🎯 Focus Now - Pending goals due today or overdue"
echo "• ✅ Completed Today - Track what you've accomplished"
echo "• 🔄 Two-view system - Today's Focus (main) vs Mission Management (secondary)"
echo ""
echo "To start the enhanced app:"
echo "1. Backend: cd backend && npm run dev"
echo "2. Frontend: cd frontend && npm start"
echo ""
echo "The app now opens directly to 'Today's Focus' - your daily command center! 🚀"
