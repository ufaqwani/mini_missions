#!/bin/bash

echo "🔧 Fixing completion tracking for Today's Focus..."
echo "Identifying and fixing completion workflow issues..."

# Navigate to project root
cd mission-tracker

echo "📝 Updating backend completion logic..."

# Fix the DailyMission model to properly handle completion timestamps
cat > backend/models/DailyMission.js << 'EOF'
const db = require('../database/database');
const { v4: uuidv4 } = require('uuid');

class DailyMission {
  static getAll() {
    return new Promise((resolve, reject) => {
      db.all(`
        SELECT dm.*, m.title as mission_title 
        FROM daily_missions dm 
        JOIN missions m ON dm.mission_id = m.id 
        ORDER BY dm.created_at DESC
      `, (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
  }

  static getByMissionId(missionId) {
    return new Promise((resolve, reject) => {
      db.all(
        'SELECT * FROM daily_missions WHERE mission_id = ? ORDER BY created_at DESC',
        [missionId],
        (err, rows) => {
          if (err) reject(err);
          else resolve(rows);
        }
      );
    });
  }

  static create(dailyMissionData) {
    return new Promise((resolve, reject) => {
      const id = uuidv4();
      const { mission_id, title, description, due_date } = dailyMissionData;
      
      db.run(
        'INSERT INTO daily_missions (id, mission_id, title, description, due_date) VALUES (?, ?, ?, ?, ?)',
        [id, mission_id, title, description, due_date],
        function(err) {
          if (err) reject(err);
          else resolve({ id, ...dailyMissionData });
        }
      );
    });
  }

  static update(id, dailyMissionData) {
    return new Promise((resolve, reject) => {
      const { title, description, status, due_date } = dailyMissionData;
      
      // Set completed_at timestamp when status changes to completed
      let completed_at = null;
      if (status === 'completed') {
        completed_at = new Date().toISOString();
      }
      
      db.run(
        'UPDATE daily_missions SET title = ?, description = ?, status = ?, due_date = ?, completed_at = ? WHERE id = ?',
        [title, description, status, due_date, completed_at, id],
        function(err) {
          if (err) reject(err);
          else resolve({ id, ...dailyMissionData, completed_at });
        }
      );
    });
  }

  static delete(id) {
    return new Promise((resolve, reject) => {
      db.run('DELETE FROM daily_missions WHERE id = ?', [id], function(err) {
        if (err) reject(err);
        else resolve({ deleted: this.changes > 0 });
      });
    });
  }
}

module.exports = DailyMission;
EOF

# Fix the today missions route with better date handling
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

// Get today's completed missions with improved date filtering
router.get('/completed', async (req, res) => {
  try {
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const tomorrow = new Date(today.getTime() + 24 * 60 * 60 * 1000);
    
    const todayStart = today.toISOString();
    const todayEnd = tomorrow.toISOString();
    
    console.log('Checking completed missions between:', todayStart, 'and', todayEnd);
    
    const completedToday = await new Promise((resolve, reject) => {
      const db = require('../database/database');
      db.all(`
        SELECT dm.*, m.title as mission_title
        FROM daily_missions dm 
        JOIN missions m ON dm.mission_id = m.id 
        WHERE dm.status = 'completed' 
        AND dm.completed_at >= ? 
        AND dm.completed_at < ?
        ORDER BY dm.completed_at DESC
      `, [todayStart, todayEnd], (err, rows) => {
        if (err) {
          console.error('Database error:', err);
          reject(err);
        } else {
          console.log('Found completed missions:', rows.length);
          resolve(rows);
        }
      });
    });
    
    res.json(completedToday);
  } catch (error) {
    console.error('Error in /completed route:', error);
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

# Update the TodayDashboard component with better completion handling
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
      setLoading(true);
      
      const [todayResponse, completedResponse] = await Promise.all([
        fetch('/api/today'),
        fetch('/api/today/completed')
      ]);
      
      if (!todayResponse.ok || !completedResponse.ok) {
        throw new Error('Failed to fetch today\'s data');
      }
      
      const todayData = await todayResponse.json();
      const completedData = await completedResponse.json();
      
      console.log('Today missions:', todayData);
      console.log('Completed today:', completedData);
      
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
    
    console.log('Toggling mission status:', mission.id, 'from', mission.status, 'to', newStatus);
    
    try {
      // Update the mission status
      const response = await dailyMissionAPI.update(mission.id, {
        title: mission.title,
        description: mission.description || '',
        mission_id: mission.mission_id,
        due_date: mission.due_date,
        status: newStatus
      });
      
      console.log('Update response:', response.data);
      
      // Refresh today's data to reflect changes
      await loadTodayData();
      
      // Also refresh parent component data
      if (onRefresh) {
        onRefresh();
      }
    } catch (error) {
      console.error('Error updating mission:', error);
      alert('Failed to update mission. Please try again.');
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
    return (
      <div style={{ 
        padding: '40px', 
        textAlign: 'center',
        backgroundColor: 'white',
        borderRadius: '8px'
      }}>
        <p>Loading today's goals...</p>
      </div>
    );
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
                      style={{ transform: 'scale(1.3)', cursor: 'pointer' }}
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
                      style={{ transform: 'scale(1.3)', cursor: 'pointer' }}
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
                          ✅ {mission.completed_at ? new Date(mission.completed_at).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'}) : 'Completed'}
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

# Add debugging endpoint to check completion data
cat > backend/routes/debug.js << 'EOF'
const express = require('express');
const router = express.Router();

// Debug endpoint to check all daily missions and their completion status
router.get('/daily-missions', async (req, res) => {
  try {
    const db = require('../database/database');
    
    const allMissions = await new Promise((resolve, reject) => {
      db.all(`
        SELECT dm.*, m.title as mission_title
        FROM daily_missions dm 
        JOIN missions m ON dm.mission_id = m.id 
        ORDER BY dm.created_at DESC
      `, (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
    
    res.json({
      total: allMissions.length,
      completed: allMissions.filter(m => m.status === 'completed').length,
      pending: allMissions.filter(m => m.status === 'pending').length,
      missions: allMissions
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
EOF

# Update server.js to include debug route
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
app.use('/api/debug', require('./routes/debug'));

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'Server is running!' });
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
EOF

echo "🔄 Restarting backend to apply fixes..."

# Kill existing backend process
pkill -f "npm run dev" 2>/dev/null || true

# Wait a moment for process to terminate
sleep 2

echo ""
echo "✅ Completion tracking fix applied!"
echo ""
echo "🔧 Key fixes made:"
echo "• ✅ Fixed completion timestamp handling in backend"
echo "• 📅 Improved date filtering for 'Completed Today' section"
echo "• 🔄 Enhanced refresh logic after completing tasks" 
echo "• 🐛 Added better error handling and logging"
echo "• 🔍 Added debug endpoint for troubleshooting"
echo ""
echo "To restart the app:"
echo "1. Backend: cd backend && npm run dev"
echo "2. Frontend should auto-refresh"
echo ""
echo "🧪 To debug completion issues, visit: http://localhost:5000/api/debug/daily-missions"
echo ""
echo "Now when you complete tasks, they should immediately show up in 'Completed Today'! ✨"
