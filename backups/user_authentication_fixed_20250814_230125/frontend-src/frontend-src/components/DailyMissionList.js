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
