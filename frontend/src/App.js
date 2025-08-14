import React, { useState, useEffect, useCallback } from 'react';
import SimpleLogin from './components/SimpleLogin';
import TodayDashboard from './components/TodayDashboard';
import MissionList from './components/MissionList';
import MissionForm from './components/MissionForm';
import DailyMissionList from './components/DailyMissionList';
import DailyMissionForm from './components/DailyMissionForm';
import { missionAPI, dailyMissionAPI } from './services/api';

function App() {
  const [currentUser, setCurrentUser] = useState(localStorage.getItem('currentUser'));
  const [missions, setMissions] = useState([]);
  const [dailyMissions, setDailyMissions] = useState([]);
  const [selectedMissionId, setSelectedMissionId] = useState(null);
  const [showMissionForm, setShowMissionForm] = useState(false);
  const [showDailyMissionForm, setShowDailyMissionForm] = useState(false);
  const [editingMission, setEditingMission] = useState(null);
  const [editingDailyMission, setEditingDailyMission] = useState(null);
  const [loading, setLoading] = useState(true);
  const [currentView, setCurrentView] = useState('today');

  const handleLogout = useCallback(() => {
    setCurrentUser(null);
    localStorage.removeItem('currentUser');
    setMissions([]);
    setDailyMissions([]);
    setSelectedMissionId(null);
  }, []);

  const loadMissions = useCallback(async () => {
    try {
      const response = await missionAPI.getAll();
      setMissions(response.data);
    } catch (error) {
      console.error('Error loading missions:', error);
      if (error.response?.status === 401) {
        handleLogout();
      }
    } finally {
      setLoading(false);
    }
  }, [handleLogout]);

  const loadDailyMissions = useCallback(async (missionId) => {
    try {
      const response = await dailyMissionAPI.getByMissionId(missionId);
      setDailyMissions(response.data);
    } catch (error) {
      console.error('Error loading daily missions:', error);
    }
  }, []);

  useEffect(() => {
    if (currentUser) {
      loadMissions();
    } else {
      setLoading(false);
    }
  }, [currentUser, loadMissions]);

  useEffect(() => {
    if (selectedMissionId && currentUser) {
      loadDailyMissions(selectedMissionId);
    } else {
      setDailyMissions([]);
    }
  }, [selectedMissionId, currentUser, loadDailyMissions]);

  const handleLogin = (username) => {
    setCurrentUser(username);
    localStorage.setItem('currentUser', username);
  };

  const handleCreateMission = async (missionData) => {
    try {
      await missionAPI.create(missionData);
      await loadMissions();
      setShowMissionForm(false);
    } catch (error) {
      console.error('Error creating mission:', error);
    }
  };

  const handleUpdateMission = async (missionData) => {
    try {
      await missionAPI.update(editingMission.id, missionData);
      await loadMissions();
      setEditingMission(null);
      setShowMissionForm(false);
    } catch (error) {
      console.error('Error updating mission:', error);
    }
  };

  const handleDeleteMission = async (missionId) => {
    try {
      await missionAPI.delete(missionId);
      await loadMissions();
      if (selectedMissionId === missionId) {
        setSelectedMissionId(null);
      }
    } catch (error) {
      console.error('Error deleting mission:', error);
    }
  };

  const handleCreateDailyMission = async (dailyMissionData) => {
    try {
      await dailyMissionAPI.create(dailyMissionData);
      await loadDailyMissions(selectedMissionId);
      setShowDailyMissionForm(false);
    } catch (error) {
      console.error('Error creating daily mission:', error);
    }
  };

  const handleUpdateDailyMission = async (dailyMissionData) => {
    try {
      await dailyMissionAPI.update(editingDailyMission.id, dailyMissionData);
      await loadDailyMissions(selectedMissionId);
      setEditingDailyMission(null);
      setShowDailyMissionForm(false);
    } catch (error) {
      console.error('Error updating daily mission:', error);
    }
  };

  const handleDeleteDailyMission = async (dailyMissionId) => {
    try {
      await dailyMissionAPI.delete(dailyMissionId);
      await loadDailyMissions(selectedMissionId);
    } catch (error) {
      console.error('Error deleting daily mission:', error);
    }
  };

  const handleToggleComplete = async (dailyMission) => {
    const newStatus = dailyMission.status === 'completed' ? 'pending' : 'completed';
    try {
      await dailyMissionAPI.update(dailyMission.id, {
        ...dailyMission,
        status: newStatus
      });
      await loadDailyMissions(selectedMissionId);
    } catch (error) {
      console.error('Error updating daily mission status:', error);
    }
  };

  const refreshData = async () => {
    await loadMissions();
    if (selectedMissionId) {
      await loadDailyMissions(selectedMissionId);
    }
  };

  // Show login screen if not authenticated
  if (!currentUser) {
    return <SimpleLogin onLogin={handleLogin} />;
  }

  // Show loading screen while data is loading
  if (loading) {
    return (
      <div className="app">
        <div className="loading">
          <div className="spinner"></div>
          <h2 className="text-2xl font-semibold" style={{ color: 'var(--gray-800)' }}>🎯 Mission Tracker</h2>
          <p style={{ color: 'var(--gray-600)' }}>Loading your productivity dashboard...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="app">
      {/* Modern Header */}
      <div className="header">
        <div className="header-content">
          <div className="logo">
            <div style={{ 
              width: '40px', 
              height: '40px', 
              background: 'linear-gradient(135deg, var(--primary-500), var(--primary-600))',
              borderRadius: '50%',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: '1.25rem'
            }}>
              🎯
            </div>
            <h1>Mission Tracker</h1>
          </div>
          
          <div className="user-menu">
            <div className="user-info">
              <div className="user-avatar">
                {currentUser.charAt(0).toUpperCase()}
              </div>
              <div>
                <div className="font-medium text-sm">Welcome back,</div>
                <div className="font-semibold" style={{ color: 'var(--gray-900)' }}>
                  {currentUser.charAt(0).toUpperCase() + currentUser.slice(1)}
                </div>
              </div>
            </div>
            <button
              onClick={handleLogout}
              className="btn"
              style={{ 
                background: 'var(--gray-100)',
                color: 'var(--gray-700)',
                border: '1px solid var(--gray-200)'
              }}
            >
              Sign Out
            </button>
          </div>
        </div>
      </div>

      <div className="main-container">
        {/* Modern Navigation */}
        <div className="nav-tabs">
          <button
            onClick={() => setCurrentView('today')}
            className={`nav-tab ${currentView === 'today' ? 'active' : ''}`}
          >
            <span>🎯</span>
            Today's Focus
          </button>
          <button
            onClick={() => setCurrentView('missions')}
            className={`nav-tab ${currentView === 'missions' ? 'active' : ''}`}
          >
            <span>📋</span>
            Mission Management
          </button>
        </div>

        {currentView === 'today' ? (
          <TodayDashboard missions={missions} onRefresh={refreshData} />
        ) : (
          <>
            <div className="card text-center mb-8">
              <div className="card-content">
                <h1 className="text-4xl font-bold" style={{ color: 'var(--gray-900)', marginBottom: 'var(--space-4)' }}>
                  📋 Mission Management
                </h1>
                <p className="text-xl" style={{ color: 'var(--gray-600)' }}>
                  Organize your long-term goals and break them into daily actionable missions
                </p>
              </div>
            </div>
            
            <div className="grid-2">
              <div>
                <div className="card">
                  <div className="card-header">
                    <h3 className="card-title">Your Missions</h3>
                    <button
                      onClick={() => {
                        setShowMissionForm(!showMissionForm);
                        setEditingMission(null);
                      }}
                      className="btn btn-primary"
                    >
                      {showMissionForm ? 'Cancel' : '+ New Mission'}
                    </button>
                  </div>
                  <div className="card-content">
                    {showMissionForm && (
                      <div className="mb-6">
                        <MissionForm
                          onSubmit={editingMission ? handleUpdateMission : handleCreateMission}
                          mission={editingMission}
                          onCancel={() => {
                            setShowMissionForm(false);
                            setEditingMission(null);
                          }}
                        />
                      </div>
                    )}

                    <MissionList
                      missions={missions}
                      selectedMissionId={selectedMissionId}
                      onSelectMission={setSelectedMissionId}
                      onEdit={(mission) => {
                        setEditingMission(mission);
                        setShowMissionForm(true);
                      }}
                      onDelete={handleDeleteMission}
                    />
                  </div>
                </div>
              </div>

              <div>
                {selectedMissionId ? (
                  <div className="card">
                    <div className="card-header">
                      <h3 className="card-title">Daily Missions</h3>
                      <button
                        onClick={() => {
                          setShowDailyMissionForm(!showDailyMissionForm);
                          setEditingDailyMission(null);
                        }}
                        className="btn btn-success"
                      >
                        {showDailyMissionForm ? 'Cancel' : '+ New Daily Mission'}
                      </button>
                    </div>
                    <div className="card-content">
                      {showDailyMissionForm && (
                        <div className="mb-6">
                          <DailyMissionForm
                            onSubmit={editingDailyMission ? handleUpdateDailyMission : handleCreateDailyMission}
                            dailyMission={editingDailyMission}
                            missionId={selectedMissionId}
                            onCancel={() => {
                              setShowDailyMissionForm(false);
                              setEditingDailyMission(null);
                            }}
                          />
                        </div>
                      )}

                      <DailyMissionList
                        dailyMissions={dailyMissions}
                        onEdit={(dailyMission) => {
                          setEditingDailyMission(dailyMission);
                          setShowDailyMissionForm(true);
                        }}
                        onDelete={handleDeleteDailyMission}
                        onToggleComplete={handleToggleComplete}
                      />
                    </div>
                  </div>
                ) : (
                  <div className="card">
                    <div className="card-content text-center" style={{ padding: 'var(--space-12)' }}>
                      <div style={{ fontSize: '4rem', marginBottom: 'var(--space-6)', opacity: '0.5' }}>📋</div>
                      <h3 className="text-2xl font-semibold mb-4" style={{ color: 'var(--gray-600)' }}>
                        Select a mission to manage daily tasks
                      </h3>
                      <p style={{ color: 'var(--gray-500)', fontSize: '1.125rem' }}>
                        Choose a mission from the left panel to start creating and managing daily actionable tasks.
                      </p>
                    </div>
                  </div>
                )}
              </div>
            </div>
          </>
        )}
      </div>
    </div>
  );
}

export default App;
