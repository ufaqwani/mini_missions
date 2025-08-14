import React, { useState, useEffect } from 'react';
import MissionList from './components/MissionList';
import MissionForm from './components/MissionForm';
import DailyMissionList from './components/DailyMissionList';
import DailyMissionForm from './components/DailyMissionForm';
import { missionAPI, dailyMissionAPI } from './services/api';

function App() {
  const [missions, setMissions] = useState([]);
  const [dailyMissions, setDailyMissions] = useState([]);
  const [selectedMissionId, setSelectedMissionId] = useState(null);
  const [showMissionForm, setShowMissionForm] = useState(false);
  const [showDailyMissionForm, setShowDailyMissionForm] = useState(false);
  const [editingMission, setEditingMission] = useState(null);
  const [editingDailyMission, setEditingDailyMission] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadMissions();
  }, []);

  useEffect(() => {
    if (selectedMissionId) {
      loadDailyMissions(selectedMissionId);
    } else {
      setDailyMissions([]);
    }
  }, [selectedMissionId]);

  const loadMissions = async () => {
    try {
      const response = await missionAPI.getAll();
      setMissions(response.data);
    } catch (error) {
      console.error('Error loading missions:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadDailyMissions = async (missionId) => {
    try {
      const response = await dailyMissionAPI.getByMissionId(missionId);
      setDailyMissions(response.data);
    } catch (error) {
      console.error('Error loading daily missions:', error);
    }
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

  if (loading) {
    return <div style={{ padding: '20px' }}>Loading...</div>;
  }

  return (
    <div style={{ maxWidth: '1200px', margin: '0 auto', padding: '20px' }}>
      <h1 style={{ textAlign: 'center', color: '#333', marginBottom: '30px' }}>
        🎯 Mission Tracker
      </h1>
      
      <div style={{ display: 'flex', gap: '30px' }}>
        {/* Left Panel - Missions */}
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

        {/* Right Panel - Daily Missions */}
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
              <h3>Select a mission to view daily missions</h3>
              <p>Click on a mission from the left panel to start managing daily missions.</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default App;
