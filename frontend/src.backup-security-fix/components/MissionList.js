import React from 'react';

const MissionList = ({ missions, onEdit, onDelete, onSelectMission, selectedMissionId }) => {
  const getStatusColor = (status) => {
    switch (status) {
      case 'completed': return '#28a745';
      case 'active': return '#007bff';
      case 'paused': return '#ffc107';
      default: return '#6c757d';
    }
  };

  return (
    <div>
      <h2>Your Missions</h2>
      {missions.length === 0 ? (
        <p>No missions yet. Create your first mission!</p>
      ) : (
        missions.map(mission => (
          <div
            key={mission.id}
            style={{
              backgroundColor: selectedMissionId === mission.id ? '#e3f2fd' : 'white',
              padding: '15px',
              marginBottom: '10px',
              borderRadius: '8px',
              border: selectedMissionId === mission.id ? '2px solid #007bff' : '1px solid #ddd',
              cursor: 'pointer'
            }}
            onClick={() => onSelectMission(mission.id)}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div style={{ flex: 1 }}>
                <h3 style={{ margin: '0 0 10px 0', color: '#333' }}>{mission.title}</h3>
                {mission.description && (
                  <p style={{ margin: '0 0 10px 0', color: '#666' }}>{mission.description}</p>
                )}
                <div style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
                  <span
                    style={{
                      backgroundColor: getStatusColor(mission.status),
                      color: 'white',
                      padding: '4px 8px',
                      borderRadius: '4px',
                      fontSize: '12px',
                      textTransform: 'uppercase'
                    }}
                  >
                    {mission.status}
                  </span>
                  
                  {mission.target_completion_date && (
                    <span style={{ color: '#666', fontSize: '14px' }}>
                      Target: {new Date(mission.target_completion_date).toLocaleDateString()}
                    </span>
                  )}
                  
                  <span style={{ color: '#666', fontSize: '12px' }}>
                    Created: {new Date(mission.created_at).toLocaleDateString()}
                  </span>
                </div>
              </div>
              
              <div style={{ display: 'flex', gap: '10px' }}>
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    onEdit(mission);
                  }}
                  style={{
                    backgroundColor: '#28a745',
                    color: 'white',
                    border: 'none',
                    padding: '6px 12px',
                    borderRadius: '4px',
                    cursor: 'pointer'
                  }}
                >
                  Edit
                </button>
                
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    if (window.confirm('Are you sure you want to delete this mission?')) {
                      onDelete(mission.id);
                    }
                  }}
                  style={{
                    backgroundColor: '#dc3545',
                    color: 'white',
                    border: 'none',
                    padding: '6px 12px',
                    borderRadius: '4px',
                    cursor: 'pointer'
                  }}
                >
                  Delete
                </button>
              </div>
            </div>
          </div>
        ))
      )}
    </div>
  );
};

export default MissionList;
