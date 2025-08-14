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
    <div className="app">
      <div className="login-container">
        <div className="login-card fade-in">
          <div className="login-title">🎯 Mission Tracker</div>
          <p className="login-subtitle">Sign in to access your productivity dashboard</p>

          {error && (
            <div style={{
              background: 'var(--danger-50)',
              color: 'var(--danger-700)',
              padding: 'var(--space-3) var(--space-4)',
              borderRadius: 'var(--radius-lg)',
              marginBottom: 'var(--space-6)',
              border: '1px solid var(--danger-200)',
              fontSize: '0.875rem'
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
                placeholder="Enter your username"
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
                placeholder="Enter your password"
                autoComplete="current-password"
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="btn btn-primary btn-lg w-full mb-6"
            >
              {loading ? (
                <>
                  <div className="spinner" style={{ width: '16px', height: '16px' }}></div>
                  Signing In...
                </>
              ) : (
                'Sign In'
              )}
            </button>
          </form>

          <div style={{ 
            padding: 'var(--space-4)',
            background: 'var(--gray-50)',
            borderRadius: 'var(--radius-lg)',
            fontSize: '0.875rem',
            color: 'var(--gray-600)'
          }}>
            <div className="font-semibold mb-2">Available Demo Users:</div>
            <div style={{ display: 'grid', gap: 'var(--space-1)' }}>
              <code style={{ background: 'white', padding: 'var(--space-1) var(--space-2)', borderRadius: 'var(--radius)' }}>
                ufaq / ufitufy
              </code>
              <code style={{ background: 'white', padding: 'var(--space-1) var(--space-2)', borderRadius: 'var(--radius)' }}>
                zia / zeetv
              </code>
              <code style={{ background: 'white', padding: 'var(--space-1) var(--space-2)', borderRadius: 'var(--radius)' }}>
                sweta / ss786
              </code>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SimpleLogin;
