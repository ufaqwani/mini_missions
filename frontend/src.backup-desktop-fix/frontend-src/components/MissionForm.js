import React, { useState } from 'react';

const MissionForm = ({ onSubmit, mission = null, onCancel }) => {
  const [formData, setFormData] = useState({
    title: mission?.title || '',
    description: mission?.description || '',
    target_completion_date: mission?.target_completion_date || '',
    status: mission?.status || 'active'
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
    <div style={{ padding: '20px', backgroundColor: 'white', borderRadius: '8px', marginBottom: '20px' }}>
      <h3>{mission ? 'Edit Mission' : 'Create New Mission'}</h3>
      <form onSubmit={handleSubmit}>
        <div style={{ marginBottom: '15px' }}>
          <label style={{ display: 'block', marginBottom: '5px' }}>Title:</label>
          <input
            type="text"
            name="title"
            value={formData.title}
            onChange={handleChange}
            required
            style={{ width: '100%', padding: '8px', borderRadius: '4px', border: '1px solid #ddd' }}
          />
        </div>
        
        <div style={{ marginBottom: '15px' }}>
          <label style={{ display: 'block', marginBottom: '5px' }}>Description:</label>
          <textarea
            name="description"
            value={formData.description}
            onChange={handleChange}
            rows="3"
            style={{ width: '100%', padding: '8px', borderRadius: '4px', border: '1px solid #ddd' }}
          />
        </div>
        
        <div style={{ marginBottom: '15px' }}>
          <label style={{ display: 'block', marginBottom: '5px' }}>Target Completion Date:</label>
          <input
            type="date"
            name="target_completion_date"
            value={formData.target_completion_date}
            onChange={handleChange}
            style={{ width: '100%', padding: '8px', borderRadius: '4px', border: '1px solid #ddd' }}
          />
        </div>

        {mission && (
          <div style={{ marginBottom: '15px' }}>
            <label style={{ display: 'block', marginBottom: '5px' }}>Status:</label>
            <select
              name="status"
              value={formData.status}
              onChange={handleChange}
              style={{ width: '100%', padding: '8px', borderRadius: '4px', border: '1px solid #ddd' }}
            >
              <option value="active">Active</option>
              <option value="completed">Completed</option>
              <option value="paused">Paused</option>
            </select>
          </div>
        )}
        
        <div>
          <button
            type="submit"
            style={{
              backgroundColor: '#007bff',
              color: 'white',
              padding: '10px 20px',
              border: 'none',
              borderRadius: '4px',
              marginRight: '10px',
              cursor: 'pointer'
            }}
          >
            {mission ? 'Update' : 'Create'} Mission
          </button>
          
          {onCancel && (
            <button
              type="button"
              onClick={onCancel}
              style={{
                backgroundColor: '#6c757d',
                color: 'white',
                padding: '10px 20px',
                border: 'none',
                borderRadius: '4px',
                cursor: 'pointer'
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

export default MissionForm;
