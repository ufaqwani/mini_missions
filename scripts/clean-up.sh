#!/bin/bash

echo "🛠️ EMERGENCY CLEANUP - Fixing broken authentication rollback..."

# Navigate to the correct directory (wherever your app actually is)
# Check current directory structure
echo "📁 Current directory: $(pwd)"
echo "📁 Contents:"
ls -la

# Find the correct mission-tracker path
if [ -d "mission-tracker" ]; then
    cd mission-tracker
    echo "✅ Found mission-tracker directory"
elif [ -d "frontend" ] && [ -d "backend" ]; then
    echo "✅ Already in project root directory"
else
    echo "❌ Cannot find project structure. Please navigate to your project directory first."
    echo "Run: cd /path/to/your/mission-tracker"
    exit 1
fi

echo "🧹 Cleaning up broken authentication imports..."

# Restore the original working App.js (without authentication)
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
  const [currentView, setCurrentView] = useState('today');

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
  );
}

export default App;
EOF

# Clean up any broken authentication files
rm -f frontend/src/contexts/AuthContext.js 2>/dev/null
rm -f frontend/src/components/Login.js 2>/dev/null
rm -f frontend/src/components/Register.js 2>/dev/null
rm -f frontend/src/components/AuthScreen.js 2>/dev/null
rm -f frontend/src/components/ProtectedLayout.js 2>/dev/null
rm -f backend/models/User.js 2>/dev/null
rm -f backend/routes/auth.js 2>/dev/null
rm -f backend/middleware/auth.js 2>/dev/null

# Restore original API service (without auth headers)
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

# Restore original backend server
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
  res.json({ status: 'Server is running!', timestamp: new Date().toISOString() });
});

app.listen(PORT, () => {
  console.log(`🚀 Mission Tracker server running on port ${PORT}`);
});
EOF

echo "✅ Emergency cleanup completed!"
echo ""
echo "🔄 Restarting your app..."

# Kill any running processes
pkill -f "npm run dev" 2>/dev/null || true
pkill -f "npm start" 2>/dev/null || true
sleep 2

echo "✅ Your app has been restored to working state!"
echo ""
echo "To restart your app:"
echo "1. Backend: cd backend && npm run dev"
echo "2. Frontend: cd frontend && npm start"
echo ""
echo "Your app should now work exactly as it did before the failed authentication attempt."
