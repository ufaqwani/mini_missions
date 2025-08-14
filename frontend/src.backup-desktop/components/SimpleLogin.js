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
    <div className="mobile-layout">
      <div style={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '20px'
      }}>
        <div style={{
          width: '100%',
          maxWidth: '400px',
          padding: '30px 20px',
          backgroundColor: 'white',
          borderRadius: '16px',
          boxShadow: '0 8px 32px rgba(0,0,0,0.1)',
          border: '1px solid #e1e5e9'
        }}>
          <div style={{ textAlign: 'center', marginBottom: '30px' }}>
            <h1 style={{ 
              margin: '0 0 8px 0', 
              color: '#333', 
              fontSize: '24px',
              fontWeight: '700'
            }}>
              🎯 Mission Tracker
            </h1>
            <p style={{ 
              margin: '0', 
              color: '#666', 
              fontSize: '16px',
              lineHeight: '1.5'
            }}>
              Please sign in to continue
            </p>
          </div>

          {error && (
            <div style={{
              backgroundColor: '#fee2e2',
              color: '#dc2626',
              padding: '12px 16px',
              borderRadius: '8px',
              marginBottom: '20px',
              fontSize: '14px',
              border: '1px solid #fecaca',
              lineHeight: '1.4'
            }}>
              {error}
            </div>
          )}

          <form onSubmit={handleSubmit} className="mobile-form">
            <div className="mobile-input-group">
              <label>Username</label>
              <input
                type="text"
                name="username"
                value={credentials.username}
                onChange={handleChange}
                required
                placeholder="Enter your username"
                style={{
                  fontSize: '16px',
                  padding: '14px',
                  borderRadius: '8px',
                  border: '2px solid #e1e5e9',
                  backgroundColor: '#fafafa'
                }}
              />
            </div>

            <div className="mobile-input-group" style={{ marginTop: '20px' }}>
              <label>Password</label>
              <input
                type="password"
                name="password"
                value={credentials.password}
                onChange={handleChange}
                required
                placeholder="Enter your password"
                style={{
                  fontSize: '16px',
                  padding: '14px',
                  borderRadius: '8px',
                  border: '2px solid #e1e5e9',
                  backgroundColor: '#fafafa'
                }}
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              style={{
                width: '100%',
                backgroundColor: loading ? '#ccc' : '#007bff',
                color: 'white',
                padding: '16px',
                border: 'none',
                borderRadius: '8px',
                fontSize: '16px',
                fontWeight: '600',
                cursor: loading ? 'not-allowed' : 'pointer',
                marginTop: '25px',
                minHeight: '50px'
              }}
            >
              {loading ? 'Signing In...' : 'Sign In'}
            </button>
          </form>

          <div style={{ 
            textAlign: 'center', 
            marginTop: '25px', 
            color: '#666', 
            fontSize: '14px',
            lineHeight: '1.5'
          }}>
            <p style={{ margin: '0' }}>
              <strong>Available users:</strong><br />
              <code style={{ 
                background: '#f1f5f9', 
                padding: '2px 6px', 
                borderRadius: '4px',
                fontSize: '13px'
              }}>
                ufaq, zia, sweta
              </code>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SimpleLogin;
