import axios from 'axios';

const API_BASE_URL = 'http://localhost:5000/api';

const api = axios.create({
  baseURL: API_BASE_URL,
});

export const missionAPI = {
  getAll: () => api.get('/missions'),
  getById: (id) => api.get(`/missions/${id}`),
  create: (data) => api.post('/missions', data),
  update: (id, data) => api.put(`/missions/${id}`, data),
  delete: (id) => api.delete(`/missions/${id}`),
};

export const dailyMissionAPI = {
  getAll: () => api.get('/daily-missions'),
  getByMissionId: (missionId) => api.get(`/daily-missions/mission/${missionId}`),
  create: (data) => api.post('/daily-missions', data),
  update: (id, data) => api.put(`/daily-missions/${id}`, data),
  delete: (id) => api.delete(`/daily-missions/${id}`),
};

export default api;
