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
      <div className="app-container">
        <div className="loading">
          <div style={{ textAlign: 'center' }}>
            <h2 style={{ color: '#333', margin: '0 0 10px 0' }}>🎯 Mission Tracker</h2>
            <p style={{ color: '#666', margin: '0' }}>Loading your missions...</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="app-container">
      {/* Desktop Header */}
      <div className="header">
        <h1>🎯 Mission Tracker</h1>
        <div className="header-user">
          <span>Welcome, <strong>{currentUser}</strong>!</span>
          <button onClick={handleLogout}>
            Logout
          </button>
        </div>
      </div>

      <div className="main-content">
        {/* Desktop Navigation */}
        <div className="navigation">
          <button
            onClick={() => setCurrentView('today')}
            className={`nav-button ${currentView === 'today' ? 'active' : ''}`}
          >
            🎯 Today's Focus
          </button>
          <button
            onClick={() => setCurrentView('missions')}
            className={`nav-button ${currentView === 'missions' ? 'active' : ''}`}
          >
            📋 Manage Missions
          </button>
        </div>

        {currentView === 'today' ? (
          <TodayDashboard missions={missions} onRefresh={refreshData} />
        ) : (
          <>
            <div className="card text-center">
              <h1 style={{ color: '#333', margin: '0 0 10px 0', fontSize: '28px' }}>
                📋 Mission Management
              </h1>
              <p style={{ color: '#666', margin: '0', fontSize: '16px' }}>
                Organize your long-term goals and create daily missions
              </p>
            </div>
            
            <div className="two-column">
              <div>
                <div className="card">
                  <button
                    onClick={() => {
                      setShowMissionForm(!showMissionForm);
                      setEditingMission(null);
                    }}
                    className="btn btn-primary btn-lg"
                    style={{ marginBottom: '20px', width: '100%' }}
                  >
                    {showMissionForm ? 'Cancel' : '+ New Mission'}
                  </button>

                  {showMissionForm && (
                    <MissionForm
                      onSubmit={editingMission ? handleUpdateMission : handleCreateMission}
                      mission={editingMission}
                      onCancel={() => {
                        setShowMissionForm(false);
                        setEditingMission(null);
                      }}
                    />
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

              <div>
                {selectedMissionId ? (
                  <div className="card">
                    <button
                      onClick={() => {
                        setShowDailyMissionForm(!showDailyMissionForm);
                        setEditingDailyMission(null);
                      }}
                      className="btn btn-success btn-lg"
                      style={{ marginBottom: '20px', width: '100%' }}
                    >
                      {showDailyMissionForm ? 'Cancel' : '+ New Daily Mission'}
                    </button>

                    {showDailyMissionForm && (
                      <DailyMissionForm
                        onSubmit={editingDailyMission ? handleUpdateDailyMission : handleCreateDailyMission}
                        dailyMission={editingDailyMission}
                        missionId={selectedMissionId}
                        onCancel={() => {
                          setShowDailyMissionForm(false);
                          setEditingDailyMission(null);
                        }}
                      />
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
                ) : (
                  <div className="card text-center">
                    <h3 style={{ color: '#666', margin: '0 0 10px 0' }}>
                      Select a mission to manage daily missions
                    </h3>
                    <p style={{ color: '#999', margin: '0' }}>
                      Click on a mission from the left panel to start managing daily missions.
                    </p>
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
