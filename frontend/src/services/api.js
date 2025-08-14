import axios from 'axios';

const API_BASE_URL = 'http://localhost:5000/api';

const api = axios.create({
  baseURL: API_BASE_URL,
});

// Add current user to requests automatically
api.interceptors.request.use(
  (config) => {
    const currentUser = localStorage.getItem('currentUser');
    if (currentUser) {
      config.headers['x-current-user'] = currentUser;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Handle authentication errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Authentication failed, redirect to login
      localStorage.removeItem('currentUser');
      window.location.reload();
    }
    return Promise.reject(error);
  }
);

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

export const todayAPI = {
  getTodayMissions: () => api.get('/today'),
  getCompletedToday: () => api.get('/today/completed'),
  quickAdd: (data) => api.post('/today/quick-add', data),
};

export const authAPI = {
  login: (data) => api.post('/auth/login', data),
  getUsers: () => api.get('/auth/users'),
};

export default api;
