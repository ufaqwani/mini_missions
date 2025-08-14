#!/bin/bash

echo "🎯 Adding Priority System to Mission Tracker..."
echo "Adding priority levels: High, Medium, Low with smart ordering..."

# Navigate to project root
cd mission-tracker

echo "📊 Updating database schema to support priorities..."

# Update database to add priority column
cat > backend/database/addPriority.js << 'EOF'
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.join(__dirname, 'missions.db');
const db = new sqlite3.Database(dbPath);

db.serialize(() => {
  // Add priority column to daily_missions table (default to medium priority)
  db.run(`ALTER TABLE daily_missions ADD COLUMN priority INTEGER DEFAULT 2`, (err) => {
    if (err && !err.message.includes('duplicate column')) {
      console.error('Error adding priority column:', err);
    } else {
      console.log('Priority column added successfully');
    }
  });
});

db.close();
EOF

# Run the database migration
cd backend
node database/addPriority.js
cd ..

echo "🔧 Updating backend models and routes..."

# Update DailyMission model to handle priority
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
        ORDER BY dm.priority ASC, dm.created_at DESC
      `, (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
  }

  static getByMissionId(missionId) {
    return new Promise((resolve, reject) => {
      db.all(
        'SELECT * FROM daily_missions WHERE mission_id = ? ORDER BY priority ASC, created_at DESC',
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
      const { mission_id, title, description, due_date, priority = 2 } = dailyMissionData;
      
      db.run(
        'INSERT INTO daily_missions (id, mission_id, title, description, due_date, priority) VALUES (?, ?, ?, ?, ?, ?)',
        [id, mission_id, title, description, due_date, priority],
        function(err) {
          if (err) reject(err);
          else resolve({ id, ...dailyMissionData, priority });
        }
      );
    });
  }

  static update(id, dailyMissionData) {
    return new Promise((resolve, reject) => {
      const { title, description, status, due_date, priority = 2 } = dailyMissionData;
      
      // Set completed_at timestamp when status changes to completed
      let completed_at = null;
      if (status === 'completed') {
        completed_at = new Date().toISOString();
      }
      
      db.run(
        'UPDATE daily_missions SET title = ?, description = ?, status = ?, due_date = ?, priority = ?, completed_at = ? WHERE id = ?',
        [title, description, status, due_date, priority, completed_at, id],
        function(err) {
          if (err) reject(err);
          else resolve({ id, ...dailyMissionData, priority, completed_at });
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

# Update today missions route to sort by priority
cat > backend/routes/todayMissions.js << 'EOF'
const express = require('express');
const router = express.Router();
const DailyMission = require('../models/DailyMission');

// Get today's missions (due today or overdue) sorted by priority
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
        ORDER BY dm.priority ASC, dm.due_date ASC, dm.created_at DESC
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

// Get today's completed missions with priority info
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
        ORDER BY dm.completed_at DESC
      `, [todayStart, todayEnd], (err, rows) => {
        if (err) {
          console.error('Database error:', err);
          reject(err);
        } else {
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

// Quick add today's mission with priority
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
    
    const dailyMission = await DailyMission.create(dailyMissionData);
    res.status(201).json(dailyMission);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
EOF

echo "🎨 Updating frontend components with priority features..."

# Update DailyMissionForm to include priority selection
cat > frontend/src/components/DailyMissionForm.js << 'EOF'
import React, { useState } from 'react';

const DailyMissionForm = ({ onSubmit, dailyMission = null, onCancel, missionId }) => {
  const [formData, setFormData] = useState({
    mission_id: dailyMission?.mission_id || missionId,
    title: dailyMission?.title || '',
    description: dailyMission?.description || '',
    due_date: dailyMission?.due_date || '',
    priority: dailyMission?.priority || 2,
    status: dailyMission?.status || 'pending'
  });

  const handleSubmit = (e) => {
    e.preventDefault();
    onSubmit(formData);
  };

  const handleChange = (e) => {
    const value = e.target.name === 'priority' ? parseInt(e.target.value) : e.target.value;
    setFormData({
      ...formData,
      [e.target.name]: value
    });
  };

  const getPriorityColor = (priority) => {
    switch (priority) {
      case 1: return '#dc3545'; // High - Red
      case 2: return '#ffc107'; // Medium - Yellow
      case 3: return '#28a745'; // Low - Green
      default: return '#6c757d';
    }
  };

  const getPriorityLabel = (priority) => {
    switch (priority) {
      case 1: return '🔴 High Priority';
      case 2: return '🟡 Medium Priority';
      case 3: return '🟢 Low Priority';
      default: return 'Select Priority';
    }
  };

  return (
    <div style={{ padding: '15px', backgroundColor: '#f8f9fa', borderRadius: '8px', marginBottom: '15px' }}>
      <h4>{dailyMission ? 'Edit Daily Mission' : 'Create New Daily Mission'}</h4>
      <form onSubmit={handleSubmit}>
        <div style={{ marginBottom: '10px' }}>
          <label style={{ display: 'block', marginBottom: '5px' }}>Title:</label>
          <input
            type="text"
            name="title"
            value={formData.title}
            onChange={handleChange}
            required
            style={{ width: '100%', padding: '6px', borderRadius: '4px', border: '1px solid #ddd' }}
          />
        </div>
        
        <div style={{ marginBottom: '10px' }}>
          <label style={{ display: 'block', marginBottom: '5px' }}>Description:</label>
          <textarea
            name="description"
            value={formData.description}
            onChange={handleChange}
            rows="2"
            style={{ width: '100%', padding: '6px', borderRadius: '4px', border: '1px solid #ddd' }}
          />
        </div>

        <div style={{ display: 'flex', gap: '10px', marginBottom: '10px' }}>
          <div style={{ flex: 1 }}>
            <label style={{ display: 'block', marginBottom: '5px' }}>Priority:</label>
            <select
              name="priority"
              value={formData.priority}
              onChange={handleChange}
              style={{ 
                width: '100%', 
                padding: '6px', 
                borderRadius: '4px', 
                border: '1px solid #ddd',
                backgroundColor: getPriorityColor(formData.priority),
                color: 'white',
                fontWeight: 'bold'
              }}
            >
              <option value={1} style={{ backgroundColor: '#dc3545', color: 'white' }}>🔴 High Priority</option>
              <option value={2} style={{ backgroundColor: '#ffc107', color: 'black' }}>🟡 Medium Priority</option>
              <option value={3} style={{ backgroundColor: '#28a745', color: 'white' }}>🟢 Low Priority</option>
            </select>
          </div>
          
          <div style={{ flex: 1 }}>
            <label style={{ display: 'block', marginBottom: '5px' }}>Due Date:</label>
            <input
              type="date"
              name="due_date"
              value={formData.due_date}
              onChange={handleChange}
              style={{ width: '100%', padding: '6px', borderRadius: '4px', border: '1px solid #ddd' }}
            />
          </div>
        </div>

        {dailyMission && (
          <div style={{ marginBottom: '10px' }}>
            <label style={{ display: 'block', marginBottom: '5px' }}>Status:</label>
            <select
              name="status"
              value={formData.status}
              onChange={handleChange}
              style={{ width: '100%', padding: '6px', borderRadius: '4px', border: '1px solid #ddd' }}
            >
              <option value="pending">Pending</option>
              <option value="completed">Completed</option>
              <option value="skipped">Skipped</option>
            </select>
          </div>
        )}
        
        <div>
          <button
            type="submit"
            style={{
              backgroundColor: '#007bff',
              color: 'white',
              padding: '8px 16px',
              border: 'none',
              borderRadius: '4px',
              marginRight: '8px',
              cursor: 'pointer',
              fontSize: '14px'
            }}
          >
            {dailyMission ? 'Update' : 'Create'}
          </button>
          
          {onCancel && (
            <button
              type="button"
              onClick={onCancel}
              style={{
                backgroundColor: '#6c757d',
                color: 'white',
                padding: '8px 16px',
                border: 'none',
                borderRadius: '4px',
                cursor: 'pointer',
                fontSize: '14px'
              }}
            >
              Cancel
            </button>
          )}
        </div>
      </form>
    </div>
  );
};

export default DailyMissionForm;
EOF

# Update DailyMissionList to show priority
cat > frontend/src/components/DailyMissionList.js << 'EOF'
import React from 'react';

const DailyMissionList = ({ dailyMissions, onEdit, onDelete, onToggleComplete }) => {
  const getStatusColor = (status) => {
    switch (status) {
      case 'completed': return '#28a745';
      case 'pending': return '#ffc107';
      case 'skipped': return '#6c757d';
      default: return '#6c757d';
    }
  };

  const getPriorityInfo = (priority) => {
    switch (priority) {
      case 1: return { color: '#dc3545', icon: '🔴', label: 'High' };
      case 2: return { color: '#ffc107', icon: '🟡', label: 'Medium' };
      case 3: return { color: '#28a745', icon: '🟢', label: 'Low' };
      default: return { color: '#6c757d', icon: '⚪', label: 'None' };
    }
  };

  // Sort missions by priority (high first) then by creation date
  const sortedMissions = [...dailyMissions].sort((a, b) => {
    if (a.priority !== b.priority) {
      return (a.priority || 2) - (b.priority || 2);
    }
    return new Date(b.created_at) - new Date(a.created_at);
  });

  return (
    <div>
      <h3>Daily Missions</h3>
      {sortedMissions.length === 0 ? (
        <p style={{ color: '#666' }}>No daily missions yet. Add some to get started!</p>
      ) : (
        sortedMissions.map(dailyMission => {
          const priorityInfo = getPriorityInfo(dailyMission.priority);
          
          return (
            <div
              key={dailyMission.id}
              style={{
                backgroundColor: 'white',
                padding: '12px',
                marginBottom: '8px',
                borderRadius: '6px',
                border: '1px solid #ddd',
                borderLeft: `4px solid ${priorityInfo.color}`,
                opacity: dailyMission.status === 'completed' ? 0.7 : 1
              }}
            >
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div style={{ flex: 1 }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                    <input
                      type="checkbox"
                      checked={dailyMission.status === 'completed'}
                      onChange={() => onToggleComplete(dailyMission)}
                      style={{ transform: 'scale(1.2)' }}
                    />
                    <span style={{ 
                      fontSize: '16px',
                      marginRight: '8px'
                    }}>
                      {priorityInfo.icon}
                    </span>
                    <h4
                      style={{
                        margin: '0',
                        textDecoration: dailyMission.status === 'completed' ? 'line-through' : 'none',
                        color: dailyMission.status === 'completed' ? '#666' : '#333'
                      }}
                    >
                      {dailyMission.title}
                    </h4>
                  </div>
                  
                  {dailyMission.description && (
                    <p style={{ margin: '5px 0', color: '#666', fontSize: '14px', marginLeft: '42px' }}>
                      {dailyMission.description}
                    </p>
                  )}
                  
                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginTop: '5px', marginLeft: '42px' }}>
                    <span
                      style={{
                        backgroundColor: priorityInfo.color,
                        color: 'white',
                        padding: '2px 6px',
                        borderRadius: '3px',
                        fontSize: '10px',
                        textTransform: 'uppercase',
                        fontWeight: 'bold'
                      }}
                    >
                      {priorityInfo.label}
                    </span>

                    <span
                      style={{
                        backgroundColor: getStatusColor(dailyMission.status),
                        color: 'white',
                        padding: '2px 6px',
                        borderRadius: '3px',
                        fontSize: '11px',
                        textTransform: 'uppercase'
                      }}
                    >
                      {dailyMission.status}
                    </span>
                    
                    {dailyMission.due_date && (
                      <span style={{ color: '#666', fontSize: '12px' }}>
                        Due: {new Date(dailyMission.due_date).toLocaleDateString()}
                      </span>
                    )}
                    
                    {dailyMission.completed_at && (
                      <span style={{ color: '#28a745', fontSize: '12px' }}>
                        ✓ Completed: {new Date(dailyMission.completed_at).toLocaleDateString()}
                      </span>
                    )}
                  </div>
                </div>
                
                <div style={{ display: 'flex', gap: '6px' }}>
                  <button
                    onClick={() => onEdit(dailyMission)}
                    style={{
                      backgroundColor: '#28a745',
                      color: 'white',
                      border: 'none',
                      padding: '4px 8px',
                      borderRadius: '3px',
                      cursor: 'pointer',
                      fontSize: '12px'
                    }}
                  >
                    Edit
                  </button>
                  
                  <button
                    onClick={() => {
                      if (window.confirm('Are you sure you want to delete this daily mission?')) {
                        onDelete(dailyMission.id);
                      }
                    }}
                    style={{
                      backgroundColor: '#dc3545',
                      color: 'white',
                      border: 'none',
                      padding: '4px 8px',
                      borderRadius: '3px',
                      cursor: 'pointer',
                      fontSize: '12px'
                    }}
                  >
                    Delete
                  </button>
                </div>
              </div>
            </div>
          );
        })
      )}
    </div>
  );
};

export default DailyMissionList;
EOF

# Update TodayDashboard with priority features
cat > frontend/src/components/TodayDashboard.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { dailyMissionAPI } from '../services/api';

const TodayDashboard = ({ missions, onRefresh }) => {
  const [todayMissions, setTodayMissions] = useState([]);
  const [completedToday, setCompletedToday] = useState([]);
  const [quickAddTitle, setQuickAddTitle] = useState('');
  const [selectedMissionId, setSelectedMissionId] = useState('');
  const [quickAddPriority, setQuickAddPriority] = useState(2);
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
          mission_id: selectedMissionId,
          priority: quickAddPriority
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
        title: mission.title,
        description: mission.description || '',
        mission_id: mission.mission_id,
        due_date: mission.due_date,
        priority: mission.priority || 2,
        status: newStatus
      });
      
      await loadTodayData();
      
      if (onRefresh) {
        onRefresh();
      }
    } catch (error) {
      console.error('Error updating mission:', error);
      alert('Failed to update mission. Please try again.');
    }
  };

  const getPriorityInfo = (priority) => {
    switch (priority) {
      case 1: return { color: '#dc3545', icon: '🔴', label: 'High', bgColor: '#fff5f5', borderColor: '#fecaca' };
      case 2: return { color: '#ffc107', icon: '🟡', label: 'Medium', bgColor: '#fffbeb', borderColor: '#fed7aa' };
      case 3: return { color: '#28a745', icon: '🟢', label: 'Low', bgColor: '#f0fff4', borderColor: '#bbf7d0' };
      default: return { color: '#6c757d', icon: '⚪', label: 'None', bgColor: '#f8f9fa', borderColor: '#e9ecef' };
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

  const getPriorityStats = () => {
    const highPriority = todayMissions.filter(m => m.priority === 1).length;
    const mediumPriority = todayMissions.filter(m => m.priority === 2).length;
    const lowPriority = todayMissions.filter(m => m.priority === 3).length;
    return { high: highPriority, medium: mediumPriority, low: lowPriority };
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

  const priorityStats = getPriorityStats();

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
        
        {/* Stats */}
        <div style={{ display: 'flex', justifyContent: 'center', gap: '20px', marginBottom: '10px', fontSize: '14px' }}>
          <span>🔴 {priorityStats.high} High</span>
          <span>🟡 {priorityStats.medium} Medium</span>
          <span>🟢 {priorityStats.low} Low</span>
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
          <div style={{ flex: 2 }}>
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
          <div style={{ minWidth: '120px' }}>
            <select
              value={quickAddPriority}
              onChange={(e) => setQuickAddPriority(parseInt(e.target.value))}
              style={{
                width: '100%',
                padding: '10px',
                borderRadius: '6px',
                border: '1px solid #ddd',
                fontSize: '14px',
                backgroundColor: getPriorityInfo(quickAddPriority).color,
                color: 'white',
                fontWeight: 'bold'
              }}
            >
              <option value={1} style={{ backgroundColor: '#dc3545', color: 'white' }}>🔴 High</option>
              <option value={2} style={{ backgroundColor: '#ffc107', color: 'black' }}>🟡 Medium</option>
              <option value={3} style={{ backgroundColor: '#28a745', color: 'white' }}>🟢 Low</option>
            </select>
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
              todayMissions.map(mission => {
                const priorityInfo = getPriorityInfo(mission.priority);
                
                return (
                  <div
                    key={mission.id}
                    style={{
                      backgroundColor: priorityInfo.bgColor,
                      border: `1px solid ${priorityInfo.borderColor}`,
                      padding: '12px',
                      marginBottom: '10px',
                      borderRadius: '6px',
                      borderLeft: `4px solid ${priorityInfo.color}`
                    }}
                  >
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                      <input
                        type="checkbox"
                        checked={false}
                        onChange={() => handleToggleComplete(mission)}
                        style={{ transform: 'scale(1.3)', cursor: 'pointer' }}
                      />
                      <span style={{ fontSize: '16px' }}>{priorityInfo.icon}</span>
                      <div style={{ flex: 1 }}>
                        <h4 style={{ margin: '0 0 5px 0', color: '#333' }}>{mission.title}</h4>
                        <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
                          <span style={{ 
                            fontSize: '10px', 
                            color: 'white',
                            backgroundColor: priorityInfo.color,
                            padding: '2px 6px',
                            borderRadius: '3px',
                            fontWeight: 'bold',
                            textTransform: 'uppercase'
                          }}>
                            {priorityInfo.label}
                          </span>
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
                );
              })
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
              completedToday.map(mission => {
                const priorityInfo = getPriorityInfo(mission.priority);
                
                return (
                  <div
                    key={mission.id}
                    style={{
                      backgroundColor: '#f0fff4',
                      border: '1px solid #bbf7d0',
                      padding: '12px',
                      marginBottom: '10px',
                      borderRadius: '6px',
                      borderLeft: `4px solid ${priorityInfo.color}`,
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
                      <span style={{ fontSize: '16px' }}>{priorityInfo.icon}</span>
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
                            fontSize: '10px', 
                            color: 'white',
                            backgroundColor: priorityInfo.color,
                            padding: '2px 6px',
                            borderRadius: '3px',
                            fontWeight: 'bold',
                            textTransform: 'uppercase'
                          }}>
                            {priorityInfo.label}
                          </span>
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
                );
              })
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default TodayDashboard;
EOF

echo "🔄 Restarting servers to apply priority system..."

# Kill existing processes
pkill -f "npm run dev" 2>/dev/null || true
pkill -f "npm start" 2>/dev/null || true

# Wait for processes to terminate
sleep 2

echo ""
echo "✅ Priority System Successfully Added!"
echo ""
echo "🎯 NEW PRIORITY FEATURES:"
echo "• 🔴 High Priority (Red) - Most urgent tasks"
echo "• 🟡 Medium Priority (Yellow) - Regular tasks" 
echo "• 🟢 Low Priority (Green) - Less urgent tasks"
echo ""
echo "📊 SMART ORDERING:"
echo "• Tasks are automatically sorted by priority (High → Medium → Low)"
echo "• Today's dashboard shows priority breakdown in header"
echo "• Visual priority indicators with color-coded borders"
echo "• Quick-add includes priority selection"
echo ""
echo "🎨 VISUAL ENHANCEMENTS:"
echo "• Color-coded task cards based on priority"
echo "• Priority icons (🔴🟡🟢) for quick identification"
echo "• Priority stats in today's focus header"
echo "• Enhanced task management forms with priority selection"
echo ""
echo "To start the enhanced app:"
echo "1. Backend: cd backend && npm run dev"
echo "2. Frontend: cd frontend && npm start"
echo ""
echo "Your high-priority tasks will now always appear first! 🚀"
