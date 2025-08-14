import React, { useState, useEffect } from 'react';
import { dailyMissionAPI } from '../services/api';
import { getOverdueInfo, getOverdueStyles } from '../utils/overdueHelpers';

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
      
      const [todayResponse, completedResponse, enhancedResponse] = await Promise.all([
        fetch('/api/today'),
        fetch('/api/today/completed'),
        fetch('/api/today/enhanced').catch(() => ({ json: () => [] }))
      ]);
      
      if (!todayResponse.ok || !completedResponse.ok) {
        throw new Error('Failed to fetch today\'s data');
      }
      
      const todayData = await todayResponse.json();
      const completedData = await completedResponse.json();
      const enhancedData = enhancedResponse.ok ? await enhancedResponse.json() : todayData;
      
      setTodayMissions(enhancedData.length > 0 ? enhancedData : todayData);
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
    const overdueCount = todayMissions.filter(m => getOverdueInfo(m).isOverdue).length;
    const criticalOverdue = todayMissions.filter(m => getOverdueInfo(m).urgency === 'critical').length;
    return { high: highPriority, medium: mediumPriority, low: lowPriority, overdue: overdueCount, critical: criticalOverdue };
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
          {priorityStats.overdue > 0 && (
            <span style={{ color: '#fef2f2', fontWeight: 'bold', animation: 'pulse 1s infinite' }}>
              {priorityStats.critical > 0 ? '🚨' : '⚠️'} {priorityStats.overdue} Overdue
            </span>
          )}
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
                const overdueInfo = getOverdueInfo(mission);
                const overdueStyles = getOverdueStyles(overdueInfo, priorityInfo);
                
                return (
                  <div
                    key={mission.id}
                    className={overdueInfo.urgency === 'critical' ? 'overdue-critical' : ''}
                    style={{
                      backgroundColor: priorityInfo.bgColor,
                      border: `1px solid ${priorityInfo.borderColor}`,
                      padding: '12px',
                      marginBottom: '10px',
                      borderRadius: '6px',
                      borderLeft: `4px solid ${priorityInfo.color}`,
                      ...overdueStyles
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
                        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '5px' }}>
                          {overdueInfo.isOverdue && (
                            <span className={`overdue-badge ${
                              overdueInfo.urgency === 'critical' ? 'overdue-critical-badge' : 'overdue-warning-badge'
                            }`}>
                              {overdueInfo.urgency === 'critical' ? '🚨 OVERDUE' : '⚠️ LATE'}
                            </span>
                          )}
                          <h4 style={{ margin: '0', color: '#333' }}>{mission.title}</h4>
                        </div>
                        
                        {overdueInfo.isOverdue && (
                          <p style={{ 
                            margin: '0 0 8px 0', 
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
