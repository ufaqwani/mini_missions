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
        // SECURE: Only store username, never password
        onLogin(data.user.username);
      } else {
        setError(data.error || 'Authentication failed');
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
    <div className="app">
      <div className="login-container">
        <div className="login-card fade-in">
          <div className="login-title">🎯 Mission Tracker</div>
          <p className="login-subtitle">
            Professional productivity management platform
          </p>

          {error && (
            <div style={{
              background: '#fef2f2',
              color: '#dc2626',
              padding: '1rem',
              borderRadius: '0.75rem',
              marginBottom: '1.5rem',
              border: '1px solid #fecaca',
              fontSize: '0.875rem',
              fontWeight: '500'
            }}>
              {error}
            </div>
          )}

          <form onSubmit={handleSubmit} className="login-form">
            <div className="form-group">
              <label className="form-label">Username</label>
              <input
                type="text"
                name="username"
                value={credentials.username}
                onChange={handleChange}
                required
                className="form-input"
                placeholder="Enter username"
                autoComplete="username"
              />
            </div>

            <div className="form-group">
              <label className="form-label">Password</label>
              <input
                type="password"
                name="password"
                value={credentials.password}
                onChange={handleChange}
                required
                className="form-input"
                placeholder="Enter password"
                autoComplete="current-password"
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="btn btn-primary w-full"
              style={{ marginBottom: '1.5rem' }}
            >
              {loading ? (
                <>
                  <div className="spinner" style={{ width: '16px', height: '16px' }}></div>
                  Authenticating...
                </>
              ) : (
                'Sign In'
              )}
            </button>
          </form>

          {/* SECURE: NO password hints or credentials shown */}
          <div style={{ 
            padding: '1rem',
            background: '#f9fafb',
            borderRadius: '0.75rem',
            fontSize: '0.875rem',
            color: '#6b7280'
          }}>
            <div className="font-semibold mb-2">Demo Access Available</div>
            <p style={{ margin: 0 }}>
              Contact administrator for credentials or use demo account access.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SimpleLogin;
