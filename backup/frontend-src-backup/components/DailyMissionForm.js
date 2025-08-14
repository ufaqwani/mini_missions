import React, { useState } from 'react';

const DailyMissionForm = ({ onSubmit, dailyMission = null, onCancel, missionId }) => {
  const [formData, setFormData] = useState({
    mission_id: dailyMission?.mission_id || missionId,
    title: dailyMission?.title || '',
    description: dailyMission?.description || '',
    due_date: dailyMission?.due_date || '',
    status: dailyMission?.status || 'pending'
  });

  const handleSubmit = (e) => {
    e.preventDefault();
    onSubmit(formData);
  };

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
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
        
        <div style={{ marginBottom: '10px' }}>
          <label style={{ display: 'block', marginBottom: '5px' }}>Due Date:</label>
          <input
            type="date"
            name="due_date"
            value={formData.due_date}
            onChange={handleChange}
            style={{ width: '100%', padding: '6px', borderRadius: '4px', border: '1px solid #ddd' }}
          />
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
