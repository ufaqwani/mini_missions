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
      <div style={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: '#f5f7fa'
      }}>
        <div style={{ textAlign: 'center' }}>
          <h2 style={{ color: '#333' }}>🎯 Mission Tracker</h2>
          <p style={{ color: '#666' }}>Loading your missions...</p>
        </div>
      </div>
    );
  }

  return (
    <div>
      {/* Top Navigation Bar */}
      <div style={{
        backgroundColor: '#007bff',
        color: 'white',
        padding: '15px 20px',
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
      }}>
        <h1 style={{ margin: 0, fontSize: '24px' }}>🎯 Mission Tracker</h1>
        
        <div style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
          <span style={{ fontSize: '14px', opacity: '0.9' }}>
            Welcome, <strong>{currentUser}</strong>!
          </span>
          <button
            onClick={handleLogout}
            style={{
              backgroundColor: 'rgba(255,255,255,0.2)',
              color: 'white',
              border: '1px solid rgba(255,255,255,0.3)',
              padding: '8px 16px',
              borderRadius: '4px',
              cursor: 'pointer',
              fontSize: '14px',
              transition: 'background-color 0.3s'
            }}
          >
            Logout
          </button>
        </div>
      </div>

      <div style={{ maxWidth: '1400px', margin: '0 auto', padding: '20px' }}>
        {/* Navigation */}
        <div style={{ 
          display: 'flex', 
          justifyContent: 'center', 
          marginBottom: '20px',
          backgroundColor: 'white',
          padding: '10px',
          borderRadius: '8px',
          border: '1px solid #ddd'
        }}>
          <button
            onClick={() => setCurrentView('today')}
            style={{
              backgroundColor: currentView === 'today' ? '#007bff' : 'transparent',
              color: currentView === 'today' ? 'white' : '#666',
              border: '1px solid #007bff',
              padding: '10px 20px',
              borderRadius: '6px 0 0 6px',
              cursor: 'pointer',
              fontSize: '16px',
              fontWeight: 'bold'
            }}
          >
            🎯 Today's Focus
          </button>
          <button
            onClick={() => setCurrentView('missions')}
            style={{
              backgroundColor: currentView === 'missions' ? '#007bff' : 'transparent',
              color: currentView === 'missions' ? 'white' : '#666',
              border: '1px solid #007bff',
              borderLeft: 'none',
              padding: '10px 20px',
              borderRadius: '0 6px 6px 0',
              cursor: 'pointer',
              fontSize: '16px',
              fontWeight: 'bold'
            }}
          >
            📋 Manage Missions
          </button>
        </div>

        {currentView === 'today' ? (
          <TodayDashboard missions={missions} onRefresh={refreshData} />
        ) : (
          <>
            <div style={{ textAlign: 'center', marginBottom: '30px' }}>
              <h1 style={{ color: '#333', margin: '0 0 10px 0' }}>📋 Mission Management</h1>
              <p style={{ color: '#666', margin: '0' }}>Organize your long-term goals and create daily missions</p>
            </div>
            
            <div style={{ display: 'flex', gap: '30px' }}>
              <div style={{ flex: 1 }}>
                <div style={{ marginBottom: '20px' }}>
                  <button
                    onClick={() => {
                      setShowMissionForm(!showMissionForm);
                      setEditingMission(null);
                    }}
                    style={{
                      backgroundColor: '#007bff',
                      color: 'white',
                      padding: '10px 20px',
                      border: 'none',
                      borderRadius: '4px',
                      cursor: 'pointer',
                      fontSize: '16px'
                    }}
                  >
                    {showMissionForm ? 'Cancel' : '+ New Mission'}
                  </button>
                </div>

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

              <div style={{ flex: 1 }}>
                {selectedMissionId ? (
                  <>
                    <div style={{ marginBottom: '20px' }}>
                      <button
                        onClick={() => {
                          setShowDailyMissionForm(!showDailyMissionForm);
                          setEditingDailyMission(null);
                        }}
                        style={{
                          backgroundColor: '#28a745',
                          color: 'white',
                          padding: '10px 20px',
                          border: 'none',
                          borderRadius: '4px',
                          cursor: 'pointer',
                          fontSize: '16px'
                        }}
                      >
                        {showDailyMissionForm ? 'Cancel' : '+ New Daily Mission'}
                      </button>
                    </div>

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

                    <div style={{ backgroundColor: 'white', padding: '20px', borderRadius: '8px' }}>
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
                  </>
                ) : (
                  <div style={{ 
                    backgroundColor: 'white', 
                    padding: '40px', 
                    borderRadius: '8px', 
                    textAlign: 'center',
                    color: '#666'
                  }}>
                    <h3>Select a mission to manage daily missions</h3>
                    <p>Click on a mission from the left panel to start managing daily missions.</p>
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
