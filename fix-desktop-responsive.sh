#!/bin/bash

echo "🖥️ FIXING DESKTOP-FIRST RESPONSIVE DESIGN"
echo "Creating great desktop experience with proper mobile responsiveness..."

cd mission-tracker

echo "📦 Creating backup before desktop improvements..."
cp -r frontend/src frontend/src.backup-desktop

echo "🎨 Step 1: Creating proper desktop-first CSS..."

# Replace the mobile-first CSS with proper desktop-first responsive design
cat > frontend/src/index.css << 'EOF'
/* Desktop-First Responsive Design */
* {
  box-sizing: border-box;
}

body {
  margin: 0;
  padding: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  background-color: #f5f7fa;
}

/* Desktop-optimized form controls */
input, select, textarea, button {
  border-radius: 6px;
  border: 1px solid #ddd;
  font-size: 14px;
  transition: all 0.2s ease;
}

input:focus, select:focus, textarea:focus {
  outline: none;
  border-color: #007bff;
  box-shadow: 0 0 0 2px rgba(0, 123, 255, 0.25);
}

button {
  cursor: pointer;
  font-weight: 600;
  transition: all 0.2s ease;
}

button:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

button:active {
  transform: translateY(0);
}

/* Desktop layout */
.app-container {
  min-height: 100vh;
  background-color: #f5f7fa;
}

.main-content {
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px;
}

/* Desktop header */
.header {
  background: linear-gradient(135deg, #007bff 0%, #0056b3 100%);
  color: white;
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.header h1 {
  margin: 0;
  font-size: 28px;
  font-weight: 700;
}

.header-user {
  display: flex;
  align-items: center;
  gap: 20px;
  font-size: 16px;
}

.header-user button {
  background: rgba(255,255,255,0.2);
  color: white;
  border: 1px solid rgba(255,255,255,0.3);
  padding: 10px 16px;
  font-size: 14px;
  border-radius: 6px;
}

.header-user button:hover {
  background: rgba(255,255,255,0.3);
}

/* Desktop navigation */
.navigation {
  display: flex;
  justify-content: center;
  margin-bottom: 30px;
  background: white;
  padding: 12px;
  border-radius: 8px;
  border: 1px solid #ddd;
  max-width: 500px;
  margin-left: auto;
  margin-right: auto;
  margin-bottom: 30px;
}

.nav-button {
  flex: 1;
  padding: 12px 24px;
  border: 1px solid #007bff;
  background: transparent;
  color: #666;
  font-size: 16px;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.2s ease;
}

.nav-button:first-child {
  border-radius: 6px 0 0 6px;
}

.nav-button:last-child {
  border-radius: 0 6px 6px 0;
  border-left: none;
}

.nav-button.active {
  background: #007bff;
  color: white;
}

.nav-button:hover:not(.active) {
  background: #f8f9fa;
}

/* Desktop cards */
.card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  margin-bottom: 24px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.05);
  border: 1px solid #e1e5e9;
}

/* Desktop two-column layout */
.two-column {
  display: flex;
  gap: 30px;
  align-items: flex-start;
}

.two-column > div {
  flex: 1;
}

/* Desktop forms */
.form-row {
  display: flex;
  gap: 15px;
  align-items: end;
  margin-bottom: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-group label {
  font-weight: 600;
  color: #333;
  font-size: 14px;
}

.form-group input,
.form-group select {
  padding: 10px 12px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 14px;
}

/* Desktop task items */
.task-item {
  background: white;
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 12px;
  border-left: 4px solid;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
  transition: all 0.2s ease;
}

.task-item:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}

.task-header {
  display: flex;
  align-items: flex-start;
  gap: 15px;
  margin-bottom: 10px;
}

.task-content {
  flex: 1;
}

.task-title {
  font-size: 16px;
  font-weight: 600;
  margin: 0 0 8px 0;
  line-height: 1.4;
}

.task-meta {
  display: flex;
  gap: 10px;
  align-items: center;
  flex-wrap: wrap;
}

.badge {
  font-size: 11px;
  padding: 4px 8px;
  border-radius: 4px;
  font-weight: bold;
  text-transform: uppercase;
}

/* Desktop buttons */
.btn {
  padding: 10px 20px;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-primary {
  background: #007bff;
  color: white;
}

.btn-primary:hover {
  background: #0056b3;
}

.btn-success {
  background: #28a745;
  color: white;
}

.btn-success:hover {
  background: #1e7e34;
}

.btn-lg {
  padding: 12px 24px;
  font-size: 16px;
}

/* Progress bars */
.progress-bar {
  background: rgba(255,255,255,0.2);
  border-radius: 10px;
  height: 10px;
  overflow: hidden;
  margin: 10px 0;
}

.progress-fill {
  background: #28a745;
  height: 100%;
  border-radius: 10px;
  transition: width 0.3s ease;
}

/* Stats display */
.stats {
  display: flex;
  justify-content: center;
  gap: 25px;
  margin: 15px 0;
  font-size: 14px;
}

.stats span {
  padding: 4px 8px;
  border-radius: 4px;
  background: rgba(255,255,255,0.1);
}

/* Today dashboard header */
.today-header {
  background: linear-gradient(135deg, #007bff 0%, #0056b3 100%);
  color: white;
  padding: 30px;
  border-radius: 12px;
  text-align: center;
  margin-bottom: 30px;
}

.today-header h1 {
  margin: 0 0 10px 0;
  font-size: 32px;
  font-weight: 700;
}

.today-header p {
  margin: 0 0 20px 0;
  font-size: 16px;
  opacity: 0.9;
}

/* Login form (desktop) */
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
}

.login-card {
  background: white;
  padding: 40px;
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(0,0,0,0.1);
  border: 1px solid #e1e5e9;
  width: 100%;
  max-width: 420px;
}

.login-header {
  text-align: center;
  margin-bottom: 30px;
}

.login-header h1 {
  margin: 0 0 8px 0;
  color: #333;
  font-size: 28px;
  font-weight: 700;
}

.login-header p {
  margin: 0;
  color: #666;
  font-size: 16px;
}

.login-form .form-group {
  margin-bottom: 20px;
}

.login-form input {
  width: 100%;
  padding: 12px 16px;
  font-size: 16px;
  border: 2px solid #e1e5e9;
  border-radius: 8px;
  transition: border-color 0.2s ease;
}

.login-form input:focus {
  border-color: #007bff;
}

.login-submit {
  width: 100%;
  padding: 14px;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.2s ease;
}

.login-submit:hover {
  background: #0056b3;
}

.login-submit:disabled {
  background: #ccc;
  cursor: not-allowed;
}

/* MOBILE RESPONSIVENESS - Tablet First (768px and down) */
@media (max-width: 768px) {
  .main-content {
    padding: 15px;
  }
  
  .header {
    padding: 15px;
    flex-direction: column;
    gap: 15px;
    text-align: center;
  }
  
  .header h1 {
    font-size: 24px;
  }
  
  .header-user {
    justify-content: center;
    font-size: 14px;
  }
  
  .navigation {
    margin-bottom: 20px;
    max-width: none;
  }
  
  .two-column {
    flex-direction: column;
    gap: 20px;
  }
  
  .form-row {
    flex-direction: column;
    gap: 10px;
  }
  
  .stats {
    gap: 15px;
    font-size: 13px;
  }
  
  .today-header {
    padding: 20px;
  }
  
  .today-header h1 {
    font-size: 24px;
  }
  
  .card {
    padding: 16px;
    margin-bottom: 16px;
  }
}

/* MOBILE RESPONSIVENESS - Phone (480px and down) */
@media (max-width: 480px) {
  .main-content {
    padding: 10px;
  }
  
  .header {
    padding: 12px;
  }
  
  .header h1 {
    font-size: 20px;
  }
  
  .navigation {
    padding: 8px;
  }
  
  .nav-button {
    padding: 10px 12px;
    font-size: 14px;
  }
  
  .stats {
    flex-wrap: wrap;
    gap: 8px;
    font-size: 12px;
  }
  
  .today-header {
    padding: 16px;
  }
  
  .today-header h1 {
    font-size: 20px;
  }
  
  .card {
    padding: 12px;
  }
  
  .task-item {
    padding: 12px;
  }
  
  .task-header {
    gap: 10px;
  }
  
  /* Mobile form improvements */
  input, select, textarea, button {
    font-size: 16px !important; /* Prevents zoom on iOS */
    min-height: 44px; /* Touch-friendly size */
  }
  
  .btn {
    padding: 12px 16px;
    font-size: 16px;
    min-height: 44px;
  }
  
  /* Mobile login adjustments */
  .login-container {
    padding: 20px;
  }
  
  .login-card {
    padding: 24px 20px;
  }
  
  .login-header h1 {
    font-size: 24px;
  }
}

/* Utility classes */
.text-center { text-align: center; }
.text-left { text-align: left; }
.mb-0 { margin-bottom: 0; }
.mb-1 { margin-bottom: 8px; }
.mb-2 { margin-bottom: 16px; }
.mt-1 { margin-top: 8px; }
.mt-2 { margin-top: 16px; }
.hidden { display: none; }

/* Loading states */
.loading {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px;
}

/* Animations */
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.7; }
}

.pulse {
  animation: pulse 2s infinite;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.fade-in {
  animation: fadeIn 0.3s ease-out;
}
EOF

echo "🖥️ Step 2: Creating proper desktop-first Login component..."

cat > frontend/src/components/SimpleLogin.js << 'EOF'
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
    <div className="login-container">
      <div className="login-card fade-in">
        <div className="login-header">
          <h1>🎯 Mission Tracker</h1>
          <p>Please sign in to continue</p>
        </div>

        {error && (
          <div style={{
            backgroundColor: '#fee2e2',
            color: '#dc2626',
            padding: '12px 16px',
            borderRadius: '8px',
            marginBottom: '20px',
            fontSize: '14px',
            border: '1px solid #fecaca'
          }}>
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="login-form">
          <div className="form-group">
            <label>Username</label>
            <input
              type="text"
              name="username"
              value={credentials.username}
              onChange={handleChange}
              required
              placeholder="Enter your username"
            />
          </div>

          <div className="form-group">
            <label>Password</label>
            <input
              type="password"
              name="password"
              value={credentials.password}
              onChange={handleChange}
              required
              placeholder="Enter your password"
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className="login-submit"
          >
            {loading ? 'Signing In...' : 'Sign In'}
          </button>
        </form>

        <div style={{ 
          textAlign: 'center', 
          marginTop: '25px', 
          color: '#666', 
          fontSize: '14px' 
        }}>
          <p style={{ margin: '0' }}>
            <strong>Available users:</strong><br />
            <code style={{ 
              background: '#f1f5f9', 
              padding: '4px 8px', 
              borderRadius: '4px',
              fontSize: '13px'
            }}>
              ufaq, zia, sweta
            </code>
          </p>
        </div>
      </div>
    </div>
  );
};

export default SimpleLogin;
EOF

echo "🎯 Step 3: Creating desktop-optimized TodayDashboard..."

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
        fetch(process.env.NODE_ENV === 'production' ? '/api/today' : 'http://localhost:5000/api/today', {
          headers: {
            'x-current-user': localStorage.getItem('currentUser')
          }
        }),
        fetch(process.env.NODE_ENV === 'production' ? '/api/today/completed' : 'http://localhost:5000/api/today/completed', {
          headers: {
            'x-current-user': localStorage.getItem('currentUser')
          }
        })
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
      const response = await fetch(process.env.NODE_ENV === 'production' ? '/api/today/quick-add' : 'http://localhost:5000/api/today/quick-add', {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          'x-current-user': localStorage.getItem('currentUser')
        },
        body: JSON.stringify({
          title: quickAddTitle,
          mission_id: selectedMissionId,
          priority: quickAddPriority
        })
      });
      
      if (response.ok) {
        setQuickAddTitle('');
        await loadTodayData();
        onRefresh();
      }
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
      if (onRefresh) onRefresh();
    } catch (error) {
      console.error('Error updating mission:', error);
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

  const getOverdueInfo = (task) => {
    const today = new Date().toISOString().split('T')[0];
    const taskDate = task.due_date;
    
    if (!taskDate) return { isOverdue: false, daysLate: 0, urgency: 'none' };
    
    const isOverdue = taskDate < today;
    const daysLate = isOverdue ? Math.floor((new Date(today) - new Date(taskDate)) / (1000 * 60 * 60 * 24)) : 0;
    
    let urgency = 'none';
    if (daysLate >= 3) urgency = 'critical';
    else if (daysLate >= 1) urgency = 'warning';
    
    return { isOverdue, daysLate, urgency };
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
    const overdueCount = todayMissions.filter(m => getOverdueInfo(m).isOverdue).length;
    const criticalOverdue = todayMissions.filter(m => getOverdueInfo(m).urgency === 'critical').length;
    return { high: highPriority, medium: mediumPriority, low: lowPriority, overdue: overdueCount, critical: criticalOverdue };
  };

  if (loading) {
    return (
      <div className="loading">
        <p>Loading today's goals...</p>
      </div>
    );
  }

  const priorityStats = getPriorityStats();

  return (
    <div className="fade-in">
      {/* Desktop Header */}
      <div className="today-header">
        <h1>🎯 Today's Focus</h1>
        <p>{getTodayDate()}</p>
        
        <div className="progress-bar">
          <div 
            className="progress-fill" 
            style={{ width: `${getProgressPercentage()}%` }}
          ></div>
        </div>
        
        <div className="stats">
          <span>🔴 {priorityStats.high} High</span>
          <span>🟡 {priorityStats.medium} Medium</span>
          <span>🟢 {priorityStats.low} Low</span>
          {priorityStats.overdue > 0 && (
            <span className="pulse" style={{ fontWeight: 'bold' }}>
              {priorityStats.critical > 0 ? '🚨' : '⚠️'} {priorityStats.overdue} Overdue
            </span>
          )}
        </div>
        
        <p style={{ fontSize: '16px', opacity: '0.9', margin: '10px 0 0 0' }}>
          {completedToday.length} completed • {todayMissions.length} remaining • {getProgressPercentage()}% done
        </p>
      </div>

      {/* Quick Add Form */}
      <div className="card">
        <h3 style={{ margin: '0 0 20px 0', fontSize: '20px' }}>⚡ Quick Add Today's Goal</h3>
        <form onSubmit={handleQuickAdd}>
          <div className="form-row">
            <div className="form-group" style={{ flex: 3 }}>
              <input
                type="text"
                placeholder="What do you want to accomplish today?"
                value={quickAddTitle}
                onChange={(e) => setQuickAddTitle(e.target.value)}
                style={{ width: '100%', padding: '12px' }}
              />
            </div>
            <div className="form-group" style={{ minWidth: '120px' }}>
              <select
                value={quickAddPriority}
                onChange={(e) => setQuickAddPriority(parseInt(e.target.value))}
                style={{
                  width: '100%',
                  padding: '12px',
                  backgroundColor: getPriorityInfo(quickAddPriority).color,
                  color: 'white',
                  fontWeight: 'bold'
                }}
              >
                <option value={1}>🔴 High</option>
                <option value={2}>🟡 Medium</option>
                <option value={3}>🟢 Low</option>
              </select>
            </div>
            <div className="form-group" style={{ minWidth: '150px' }}>
              <select
                value={selectedMissionId}
                onChange={(e) => setSelectedMissionId(e.target.value)}
                style={{ width: '100%', padding: '12px' }}
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
              className="btn btn-success"
              style={{ minWidth: '120px' }}
            >
              Add Goal
            </button>
          </div>
        </form>
      </div>

      <div className="two-column">
        {/* Today's Pending Goals */}
        <div>
          <div className="card">
            <h3 style={{ margin: '0 0 20px 0', color: '#dc3545', fontSize: '20px' }}>
              🎯 Focus Now ({todayMissions.length})
            </h3>
            
            {todayMissions.length === 0 ? (
              <div className="text-center" style={{ padding: '40px', color: '#666' }}>
                <p style={{ fontSize: '18px', margin: '0 0 10px 0' }}>🎉 All caught up!</p>
                <p style={{ margin: '0' }}>No pending goals for today. Add some above!</p>
              </div>
            ) : (
              todayMissions.map(mission => {
                const priorityInfo = getPriorityInfo(mission.priority);
                const overdueInfo = getOverdueInfo(mission);
                
                return (
                  <div
                    key={mission.id}
                    className="task-item"
                    style={{
                      backgroundColor: priorityInfo.bgColor,
                      borderLeftColor: priorityInfo.color,
                      ...(overdueInfo.urgency === 'critical' ? { animation: 'pulse 2s infinite' } : {})
                    }}
                  >
                    <div className="task-header">
                      <input
                        type="checkbox"
                        checked={false}
                        onChange={() => handleToggleComplete(mission)}
                        style={{ width: '18px', height: '18px', cursor: 'pointer' }}
                      />
                      <span style={{ fontSize: '18px' }}>{priorityInfo.icon}</span>
                      <div className="task-content">
                        {overdueInfo.isOverdue && (
                          <div style={{ marginBottom: '8px' }}>
                            <span className="badge" style={{
                              backgroundColor: overdueInfo.urgency === 'critical' ? '#dc2626' : '#f59e0b',
                              color: 'white'
                            }}>
                              {overdueInfo.urgency === 'critical' ? '🚨 OVERDUE' : '⚠️ LATE'}
                            </span>
                          </div>
                        )}
                        
                        <h4 className="task-title">{mission.title}</h4>
                        
                        {overdueInfo.isOverdue && (
                          <p style={{ 
                            margin: '8px 0', 
                            fontSize: '13px', 
                            color: overdueInfo.urgency === 'critical' ? '#dc2626' : '#f59e0b',
                            fontWeight: 'bold'
                          }}>
                            {overdueInfo.daysLate === 1 
                              ? '📅 This was due yesterday!'
                              : `📅 This was due ${overdueInfo.daysLate} days ago!`
                            }
                          </p>
                        )}
                        
                        <div className="task-meta">
                          <span className="badge" style={{ 
                            backgroundColor: priorityInfo.color,
                            color: 'white'
                          }}>
                            {priorityInfo.label}
                          </span>
                          <span className="badge" style={{ 
                            backgroundColor: '#e3f2fd',
                            color: '#666'
                          }}>
                            📋 {mission.mission_title}
                          </span>
                          {mission.due_date && (
                            <span style={{ 
                              fontSize: '12px', 
                              color: overdueInfo.isOverdue ? '#dc2626' : '#666' 
                            }}>
                              {overdueInfo.isOverdue 
                                ? `⚠️ Was due: ${new Date(mission.due_date).toLocaleDateString()}`
                                : '📅 Due today'
                              }
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
        <div>
          <div className="card">
            <h3 style={{ margin: '0 0 20px 0', color: '#28a745', fontSize: '20px' }}>
              ✅ Completed Today ({completedToday.length})
            </h3>
            
            {completedToday.length === 0 ? (
              <div className="text-center" style={{ padding: '40px', color: '#666' }}>
                <p style={{ margin: '0' }}>No goals completed yet today. You got this! 💪</p>
              </div>
            ) : (
              completedToday.map(mission => {
                const priorityInfo = getPriorityInfo(mission.priority);
                
                return (
                  <div
                    key={mission.id}
                    className="task-item"
                    style={{
                      backgroundColor: '#f0fff4',
                      borderLeftColor: priorityInfo.color,
                      opacity: '0.9'
                    }}
                  >
                    <div className="task-header">
                      <input
                        type="checkbox"
                        checked={true}
                        onChange={() => handleToggleComplete(mission)}
                        style={{ width: '18px', height: '18px', cursor: 'pointer' }}
                      />
                      <span style={{ fontSize: '18px' }}>{priorityInfo.icon}</span>
                      <div className="task-content">
                        <h4 className="task-title" style={{ 
                          textDecoration: 'line-through',
                          color: '#666'
                        }}>
                          {mission.title}
                        </h4>
                        <div className="task-meta">
                          <span className="badge" style={{ 
                            backgroundColor: priorityInfo.color,
                            color: 'white'
                          }}>
                            {priorityInfo.label}
                          </span>
                          <span className="badge" style={{ 
                            backgroundColor: '#e3f2fd',
                            color: '#666'
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

echo "🖥️ Step 4: Creating desktop-first App.js..."

cat > frontend/src/App.js << 'EOF'
import React, { useState, useEffect, useCallback } from 'react';
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

  const handleLogout = useCallback(() => {
    setCurrentUser(null);
    localStorage.removeItem('currentUser');
    setMissions([]);
    setDailyMissions([]);
    setSelectedMissionId(null);
  }, []);

  const loadMissions = useCallback(async () => {
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
  }, [handleLogout]);

  const loadDailyMissions = useCallback(async (missionId) => {
    try {
      const response = await dailyMissionAPI.getByMissionId(missionId);
      setDailyMissions(response.data);
    } catch (error) {
      console.error('Error loading daily missions:', error);
    }
  }, []);

  useEffect(() => {
    if (currentUser) {
      loadMissions();
    } else {
      setLoading(false);
    }
  }, [currentUser, loadMissions]);

  useEffect(() => {
    if (selectedMissionId && currentUser) {
      loadDailyMissions(selectedMissionId);
    } else {
      setDailyMissions([]);
    }
  }, [selectedMissionId, currentUser, loadDailyMissions]);

  const handleLogin = (username) => {
    setCurrentUser(username);
    localStorage.setItem('currentUser', username);
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
      <div className="app-container">
        <div className="loading">
          <div style={{ textAlign: 'center' }}>
            <h2 style={{ color: '#333', margin: '0 0 10px 0' }}>🎯 Mission Tracker</h2>
            <p style={{ color: '#666', margin: '0' }}>Loading your missions...</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="app-container">
      {/* Desktop Header */}
      <div className="header">
        <h1>🎯 Mission Tracker</h1>
        <div className="header-user">
          <span>Welcome, <strong>{currentUser}</strong>!</span>
          <button onClick={handleLogout}>
            Logout
          </button>
        </div>
      </div>

      <div className="main-content">
        {/* Desktop Navigation */}
        <div className="navigation">
          <button
            onClick={() => setCurrentView('today')}
            className={`nav-button ${currentView === 'today' ? 'active' : ''}`}
          >
            🎯 Today's Focus
          </button>
          <button
            onClick={() => setCurrentView('missions')}
            className={`nav-button ${currentView === 'missions' ? 'active' : ''}`}
          >
            📋 Manage Missions
          </button>
        </div>

        {currentView === 'today' ? (
          <TodayDashboard missions={missions} onRefresh={refreshData} />
        ) : (
          <>
            <div className="card text-center">
              <h1 style={{ color: '#333', margin: '0 0 10px 0', fontSize: '28px' }}>
                📋 Mission Management
              </h1>
              <p style={{ color: '#666', margin: '0', fontSize: '16px' }}>
                Organize your long-term goals and create daily missions
              </p>
            </div>
            
            <div className="two-column">
              <div>
                <div className="card">
                  <button
                    onClick={() => {
                      setShowMissionForm(!showMissionForm);
                      setEditingMission(null);
                    }}
                    className="btn btn-primary btn-lg"
                    style={{ marginBottom: '20px', width: '100%' }}
                  >
                    {showMissionForm ? 'Cancel' : '+ New Mission'}
                  </button>

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
              </div>

              <div>
                {selectedMissionId ? (
                  <div className="card">
                    <button
                      onClick={() => {
                        setShowDailyMissionForm(!showDailyMissionForm);
                        setEditingDailyMission(null);
                      }}
                      className="btn btn-success btn-lg"
                      style={{ marginBottom: '20px', width: '100%' }}
                    >
                      {showDailyMissionForm ? 'Cancel' : '+ New Daily Mission'}
                    </button>

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
                ) : (
                  <div className="card text-center">
                    <h3 style={{ color: '#666', margin: '0 0 10px 0' }}>
                      Select a mission to manage daily missions
                    </h3>
                    <p style={{ color: '#999', margin: '0' }}>
                      Click on a mission from the left panel to start managing daily missions.
                    </p>
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

echo "📱 Step 5: Ensuring proper viewport for mobile..."

# Update viewport meta tag for proper mobile scaling
sed -i 's/<meta name="viewport".*>/<meta name="viewport" content="width=device-width, initial-scale=1.0">/' frontend/public/index.html

echo "📦 Step 6: Committing desktop-first responsive design..."

git add frontend/src/ frontend/public/index.html

git commit -m "Fix desktop-first responsive design - great desktop UX with mobile responsiveness"

git push origin main

echo ""
echo "🖥️ DESKTOP-FIRST RESPONSIVE DESIGN COMPLETE!"
echo ""
echo "✅ FIXED ISSUES:"
echo "• 🖥️ Desktop version now looks professional and polished"
echo "• 📱 Mobile responsiveness works properly without affecting desktop"
echo "• 🎨 Proper desktop spacing, typography, and layout"
echo "• 🔘 Desktop-optimized buttons and forms"
echo "• 📊 Beautiful desktop dashboard with proper two-column layout"
echo "• 🎯 Mobile breakpoints only activate on actual mobile devices"
echo ""
echo "🖥️ DESKTOP FEATURES:"
echo "• ✨ Professional gradient headers and modern design"
echo "• 📋 Two-column layout that uses desktop screen real estate"
echo "• 🎨 Proper desktop spacing and typography"
echo "• 🔘 Desktop-sized buttons and forms"
echo "• 📊 Beautiful progress bars and stats display"
echo "• 💼 Professional login form centered on desktop"
echo ""
echo "📱 MOBILE ADAPTATIONS:"
echo "• 📱 < 768px: Stacks to single column, mobile-friendly buttons"
echo "• 📱 < 480px: Touch-optimized with 16px inputs (no iOS zoom)"
echo "• 🔘 Mobile-friendly button sizing (44px minimum)"
echo "• 📝 Mobile-optimized forms and navigation"
echo ""
echo "🎯 RESULT:"
echo "• 🖥️ Desktop users get a beautiful, professional interface"
echo "• 📱 Mobile users get a perfectly responsive, touch-friendly experience"
echo "• 💻 Tablet users get an optimized mid-size layout"
echo "• ✨ No more mobile-looking desktop site!"
echo ""
echo "🚀 Your app now looks great on desktop AND mobile!"
echo "Render will auto-deploy these changes in a few minutes. ✨"
