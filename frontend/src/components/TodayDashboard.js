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
      case 1: return { color: 'var(--danger-500)', icon: '🔴', label: 'High', class: 'priority-high' };
      case 2: return { color: 'var(--warning-500)', icon: '🟡', label: 'Medium', class: 'priority-medium' };
      case 3: return { color: 'var(--success-500)', icon: '🟢', label: 'Low', class: 'priority-low' };
      default: return { color: 'var(--gray-400)', icon: '⚪', label: 'None', class: 'priority-none' };
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
        <div className="spinner"></div>
        <p style={{ color: 'var(--gray-600)' }}>Loading your daily focus...</p>
      </div>
    );
  }

  const priorityStats = getPriorityStats();

  return (
    <div className="fade-in">
      {/* FIXED: Use proper CSS classes for desktop hero */}
      <div className="today-hero">
        <div className="today-title">🎯 Today's Focus</div>
        <div className="today-subtitle">{getTodayDate()}</div>
        
        <div className="progress-container">
          <div 
            className="progress-bar" 
            style={{ width: `${getProgressPercentage()}%` }}
          ></div>
        </div>
        
        {/* FIXED: Use proper CSS classes for desktop stats grid */}
        <div className="stats-grid">
          <div className="stat-item">
            <div className="stat-value">🔴 {priorityStats.high}</div>
            <div className="stat-label">High Priority</div>
          </div>
          <div className="stat-item">
            <div className="stat-value">🟡 {priorityStats.medium}</div>
            <div className="stat-label">Medium Priority</div>
          </div>
          <div className="stat-item">
            <div className="stat-value">🟢 {priorityStats.low}</div>
            <div className="stat-label">Low Priority</div>
          </div>
          {priorityStats.overdue > 0 && (
            <div className="stat-item">
              <div className="stat-value">
                {priorityStats.critical > 0 ? '🚨' : '⚠️'} {priorityStats.overdue}
              </div>
              <div className="stat-label">Overdue Tasks</div>
            </div>
          )}
        </div>
        
        <p style={{ fontSize: '1.125rem', opacity: '0.9', margin: '0' }}>
          <strong>{completedToday.length}</strong> completed • <strong>{todayMissions.length}</strong> remaining • <strong>{getProgressPercentage()}%</strong> done
        </p>
      </div>

      {/* Quick Add Form */}
      <div className="card mb-8">
        <div className="card-header">
          <h3 className="card-title">⚡ Quick Add Today's Goal</h3>
        </div>
        <div className="card-content">
          <form onSubmit={handleQuickAdd}>
            {/* FIXED: Use proper CSS classes for desktop form grid */}
            <div className="grid-form">
              <div className="form-group" style={{ marginBottom: 0 }}>
                <input
                  type="text"
                  placeholder="What do you want to accomplish today?"
                  value={quickAddTitle}
                  onChange={(e) => setQuickAddTitle(e.target.value)}
                  className="form-input"
                />
              </div>
              <div className="form-group" style={{ marginBottom: 0 }}>
                <select
                  value={quickAddPriority}
                  onChange={(e) => setQuickAddPriority(parseInt(e.target.value))}
                  className="form-select"
                  style={{ background: getPriorityInfo(quickAddPriority).color, color: 'white', fontWeight: '600' }}
                >
                  <option value={1}>🔴 High</option>
                  <option value={2}>🟡 Medium</option>
                  <option value={3}>🟢 Low</option>
                </select>
              </div>
              <div className="form-group" style={{ marginBottom: 0 }}>
                <select
                  value={selectedMissionId}
                  onChange={(e) => setSelectedMissionId(e.target.value)}
                  className="form-select"
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
              >
                Add Goal
              </button>
            </div>
          </form>
        </div>
      </div>

      {/* FIXED: Use proper CSS classes for desktop two-column grid */}
      <div className="grid-2">
        {/* Today's Pending Goals */}
        <div className="card">
          <div className="card-header">
            <h3 className="card-title" style={{ color: 'var(--danger-600)' }}>
              🎯 Focus Now ({todayMissions.length})
            </h3>
          </div>
          <div className="card-content">
            {todayMissions.length === 0 ? (
              <div className="text-center" style={{ padding: 'var(--space-12)', color: 'var(--gray-500)' }}>
                <div style={{ fontSize: '3rem', marginBottom: 'var(--space-4)' }}>🎉</div>
                <h4 className="text-xl font-semibold mb-4">All caught up!</h4>
                <p>No pending goals for today. Add some above to get started!</p>
              </div>
            ) : (
              <div className="task-list">
                {todayMissions.map(mission => {
                  const priorityInfo = getPriorityInfo(mission.priority);
                  const overdueInfo = getOverdueInfo(mission);
                  
                  return (
                    <div
                      key={mission.id}
                      className={`task-item ${priorityInfo.class}`}
                    >
                      <div className="task-header">
                        <input
                          type="checkbox"
                          checked={false}
                          onChange={() => handleToggleComplete(mission)}
                          className="task-checkbox"
                        />
                        <span style={{ fontSize: '1.25rem' }}>{priorityInfo.icon}</span>
                        <div className="task-content">
                          {overdueInfo.isOverdue && (
                            <div style={{ marginBottom: 'var(--space-2)' }}>
                              <span className="badge" style={{ 
                                background: 'var(--danger-500)', 
                                color: 'white' 
                              }}>
                                {overdueInfo.urgency === 'critical' ? '🚨 CRITICAL OVERDUE' : '⚠️ OVERDUE'}
                              </span>
                            </div>
                          )}
                          
                          <h4 className="task-title">{mission.title}</h4>
                          
                          {overdueInfo.isOverdue && (
                            <p style={{ 
                              margin: 'var(--space-2) 0', 
                              fontSize: '0.875rem', 
                              color: 'var(--danger-600)',
                              fontWeight: '600'
                            }}>
                              {overdueInfo.daysLate === 1 
                                ? '📅 This was due yesterday!'
                                : `📅 This was due ${overdueInfo.daysLate} days ago!`
                              }
                            </p>
                          )}
                          
                          <div className="task-meta">
                            <span className={`badge badge-${priorityInfo.label.toLowerCase()}`}>
                              {priorityInfo.icon} {priorityInfo.label}
                            </span>
                            <span className="badge" style={{ 
                              background: 'var(--primary-50)',
                              color: 'var(--primary-700)',
                              border: '1px solid var(--primary-200)'
                            }}>
                              📋 {mission.mission_title}
                            </span>
                            {mission.due_date && (
                              <span style={{ 
                                fontSize: '0.75rem', 
                                color: overdueInfo.isOverdue ? 'var(--danger-600)' : 'var(--gray-500)',
                                fontWeight: overdueInfo.isOverdue ? '600' : 'normal'
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
                })}
              </div>
            )}
          </div>
        </div>

        {/* Today's Completed Goals */}
        <div className="card">
          <div className="card-header">
            <h3 className="card-title" style={{ color: 'var(--success-600)' }}>
              ✅ Completed Today ({completedToday.length})
            </h3>
          </div>
          <div className="card-content">
            {completedToday.length === 0 ? (
              <div className="text-center" style={{ padding: 'var(--space-12)', color: 'var(--gray-500)' }}>
                <div style={{ fontSize: '3rem', marginBottom: 'var(--space-4)' }}>💪</div>
                <h4 className="text-xl font-semibold mb-4">Ready to achieve?</h4>
                <p>No goals completed yet today. You got this!</p>
              </div>
            ) : (
              <div className="task-list">
                {completedToday.map(mission => {
                  const priorityInfo = getPriorityInfo(mission.priority);
                  
                  return (
                    <div
                      key={mission.id}
                      className="task-item"
                      style={{ opacity: '0.9', background: 'var(--success-50)' }}
                    >
                      <div className="task-header">
                        <input
                          type="checkbox"
                          checked={true}
                          onChange={() => handleToggleComplete(mission)}
                          className="task-checkbox"
                        />
                        <span style={{ fontSize: '1.25rem' }}>{priorityInfo.icon}</span>
                        <div className="task-content">
                          <h4 className="task-title" style={{ 
                            textDecoration: 'line-through',
                            color: 'var(--gray-600)'
                          }}>
                            {mission.title}
                          </h4>
                          <div className="task-meta">
                            <span className={`badge badge-${priorityInfo.label.toLowerCase()}`}>
                              {priorityInfo.icon} {priorityInfo.label}
                            </span>
                            <span className="badge" style={{ 
                              background: 'var(--primary-50)',
                              color: 'var(--primary-700)',
                              border: '1px solid var(--primary-200)'
                            }}>
                              📋 {mission.mission_title}
                            </span>
                            <span className="badge" style={{
                              background: 'var(--success-100)',
                              color: 'var(--success-700)',
                              border: '1px solid var(--success-300)'
                            }}>
                              ✅ {mission.completed_at ? new Date(mission.completed_at).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'}) : 'Completed'}
                            </span>
                          </div>
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default TodayDashboard;
