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
      } else {
        console.error('Failed to add quick mission');
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
      <div className="mobile-card">
        <p style={{ textAlign: 'center', margin: '20px 0' }}>Loading today's goals...</p>
      </div>
    );
  }

  const priorityStats = getPriorityStats();

  return (
    <div>
      {/* Mobile-friendly Header */}
      <div className="mobile-card" style={{ 
        background: 'linear-gradient(135deg, #007bff 0%, #0056b3 100%)',
        color: 'white',
        textAlign: 'center'
      }}>
        <h1 style={{ margin: '0 0 8px 0', fontSize: '24px', fontWeight: '700' }}>
          🎯 Today's Focus
        </h1>
        <p style={{ margin: '0 0 16px 0', fontSize: '14px', opacity: '0.9' }}>
          {getTodayDate()}
        </p>
        
        {/* Progress Bar */}
        <div style={{ 
          backgroundColor: 'rgba(255,255,255,0.2)', 
          borderRadius: '10px', 
          height: '8px', 
          marginBottom: '12px',
          overflow: 'hidden'
        }}>
          <div style={{ 
            backgroundColor: '#28a745', 
            height: '100%', 
            borderRadius: '10px',
            width: `${getProgressPercentage()}%`,
            transition: 'width 0.3s ease'
          }}></div>
        </div>
        
        {/* Mobile Stats */}
        <div style={{ 
          display: 'flex', 
          justifyContent: 'center', 
          flexWrap: 'wrap',
          gap: '12px', 
          marginBottom: '12px', 
          fontSize: '13px' 
        }}>
          <span>🔴 {priorityStats.high}</span>
          <span>🟡 {priorityStats.medium}</span>
          <span>🟢 {priorityStats.low}</span>
          {priorityStats.overdue > 0 && (
            <span style={{ fontWeight: 'bold' }}>
              {priorityStats.critical > 0 ? '🚨' : '⚠️'} {priorityStats.overdue} Overdue
            </span>
          )}
        </div>
        
        <p style={{ margin: '0', fontSize: '14px', opacity: '0.9' }}>
          {completedToday.length} completed • {todayMissions.length} remaining • {getProgressPercentage()}% done
        </p>
      </div>

      {/* Mobile Quick Add */}
      <div className="mobile-card">
        <h3 style={{ margin: '0 0 16px 0', color: '#333', fontSize: '18px' }}>
          ⚡ Quick Add Today's Goal
        </h3>
        <form onSubmit={handleQuickAdd}>
          <div className="mobile-form-row">
            <div style={{ flex: 2 }}>
              <input
                type="text"
                placeholder="What do you want to accomplish today?"
                value={quickAddTitle}
                onChange={(e) => setQuickAddTitle(e.target.value)}
                style={{
                  fontSize: '16px',
                  padding: '12px',
                  borderRadius: '8px',
                  border: '2px solid #e1e5e9'
                }}
              />
            </div>
            <div style={{ minWidth: '100px' }}>
              <select
                value={quickAddPriority}
                onChange={(e) => setQuickAddPriority(parseInt(e.target.value))}
                style={{
                  fontSize: '16px',
                  padding: '12px',
                  borderRadius: '8px',
                  border: '2px solid #e1e5e9',
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
            <div style={{ minWidth: '120px' }}>
              <select
                value={selectedMissionId}
                onChange={(e) => setSelectedMissionId(e.target.value)}
                style={{
                  fontSize: '16px',
                  padding: '12px',
                  borderRadius: '8px',
                  border: '2px solid #e1e5e9'
                }}
              >
                <option value="">Select Mission</option>
                {missions.filter(m => m.status === 'active').map(mission => (
                  <option key={mission.id} value={mission.id}>
                    {mission.title.length > 20 ? mission.title.substring(0, 20) + '...' : mission.title}
                  </option>
                ))}
              </select>
            </div>
            <button
              type="submit"
              disabled={!quickAddTitle.trim() || !selectedMissionId}
              style={{
                backgroundColor: (!quickAddTitle.trim() || !selectedMissionId) ? '#ccc' : '#28a745',
                color: 'white',
                border: 'none',
                padding: '12px 16px',
                borderRadius: '8px',
                fontSize: '16px',
                fontWeight: '600',
                minHeight: '48px'
              }}
            >
              Add Goal
            </button>
          </div>
        </form>
      </div>

      {/* Mobile Task Lists */}
      <div className="mobile-two-column">
        {/* Today's Pending Goals */}
        <div>
          <div className="mobile-card">
            <h3 style={{ 
              margin: '0 0 16px 0', 
              color: '#dc3545', 
              fontSize: '18px',
              fontWeight: '600'
            }}>
              🎯 Focus Now ({todayMissions.length})
            </h3>
            
            {todayMissions.length === 0 ? (
              <div style={{ textAlign: 'center', color: '#666', padding: '20px' }}>
                <p style={{ fontSize: '16px', margin: '0 0 8px 0' }}>🎉 All caught up!</p>
                <p style={{ margin: '0', fontSize: '14px' }}>No pending goals for today.</p>
              </div>
            ) : (
              todayMissions.map(mission => {
                const priorityInfo = getPriorityInfo(mission.priority);
                const overdueInfo = getOverdueInfo(mission);
                
                return (
                  <div
                    key={mission.id}
                    className="mobile-task"
                    style={{
                      backgroundColor: priorityInfo.bgColor,
                      borderLeftColor: priorityInfo.color,
                      ...(overdueInfo.urgency === 'critical' ? { animation: 'pulse 2s infinite' } : {})
                    }}
                  >
                    <div className="mobile-task-header">
                      <input
                        type="checkbox"
                        checked={false}
                        onChange={() => handleToggleComplete(mission)}
                        style={{ margin: '2px 0 0 0' }}
                      />
                      <span style={{ fontSize: '18px' }}>{priorityInfo.icon}</span>
                      <div className="mobile-task-content">
                        <div style={{ marginBottom: '8px' }}>
                          {overdueInfo.isOverdue && (
                            <span className="mobile-badge" style={{
                              backgroundColor: overdueInfo.urgency === 'critical' ? '#dc2626' : '#f59e0b',
                              color: 'white',
                              marginRight: '6px'
                            }}>
                              {overdueInfo.urgency === 'critical' ? '🚨 OVERDUE' : '⚠️ LATE'}
                            </span>
                          )}
                        </div>
                        
                        <h4 className="mobile-task-title">{mission.title}</h4>
                        
                        {overdueInfo.isOverdue && (
                          <p style={{ 
                            margin: '4px 0 8px 0', 
                            fontSize: '12px', 
                            color: overdueInfo.urgency === 'critical' ? '#dc2626' : '#f59e0b',
                            fontWeight: 'bold'
                          }}>
                            {overdueInfo.daysLate === 1 
                              ? '📅 This was due yesterday!'
                              : `📅 This was due ${overdueInfo.daysLate} days ago!`
                            }
                          </p>
                        )}
                        
                        <div className="mobile-task-meta">
                          <span className="mobile-badge" style={{ 
                            backgroundColor: priorityInfo.color,
                            color: 'white'
                          }}>
                            {priorityInfo.label}
                          </span>
                          <span className="mobile-badge" style={{ 
                            backgroundColor: '#e3f2fd',
                            color: '#666'
                          }}>
                            📋 {mission.mission_title}
                          </span>
                          {mission.due_date && (
                            <span style={{ 
                              fontSize: '11px', 
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
          <div className="mobile-card">
            <h3 style={{ 
              margin: '0 0 16px 0', 
              color: '#28a745', 
              fontSize: '18px',
              fontWeight: '600'
            }}>
              ✅ Completed Today ({completedToday.length})
            </h3>
            
            {completedToday.length === 0 ? (
              <div style={{ textAlign: 'center', color: '#666', padding: '20px' }}>
                <p style={{ margin: '0', fontSize: '14px' }}>No goals completed yet today. You got this! 💪</p>
              </div>
            ) : (
              completedToday.map(mission => {
                const priorityInfo = getPriorityInfo(mission.priority);
                
                return (
                  <div
                    key={mission.id}
                    className="mobile-task"
                    style={{
                      backgroundColor: '#f0fff4',
                      borderLeftColor: priorityInfo.color,
                      opacity: '0.9'
                    }}
                  >
                    <div className="mobile-task-header">
                      <input
                        type="checkbox"
                        checked={true}
                        onChange={() => handleToggleComplete(mission)}
                        style={{ margin: '2px 0 0 0' }}
                      />
                      <span style={{ fontSize: '18px' }}>{priorityInfo.icon}</span>
                      <div className="mobile-task-content">
                        <h4 className="mobile-task-title" style={{ 
                          textDecoration: 'line-through',
                          color: '#666'
                        }}>
                          {mission.title}
                        </h4>
                        <div className="mobile-task-meta">
                          <span className="mobile-badge" style={{ 
                            backgroundColor: priorityInfo.color,
                            color: 'white'
                          }}>
                            {priorityInfo.label}
                          </span>
                          <span className="mobile-badge" style={{ 
                            backgroundColor: '#e3f2fd',
                            color: '#666'
                          }}>
                            📋 {mission.mission_title}
                          </span>
                          <span style={{ fontSize: '11px', color: '#28a745' }}>
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
