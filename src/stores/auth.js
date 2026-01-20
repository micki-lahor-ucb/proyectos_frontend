import { defineStore } from 'pinia';
import apiClient from '../services/api';

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: JSON.parse(localStorage.getItem('user')) || null,
    token: localStorage.getItem('token') || null,
    loading: false,
    error: null,
  }),
  
  getters: {
    isAuthenticated: (state) => !!state.token,
    getUser: (state) => state.user,
  },
  
  actions: {
    async login(credentials) {
      this.loading = true;
      this.error = null;
      
      try {
        const response = await apiClient.post('/auth/login', credentials);
        const { access_token, user } = response.data;
        
        // Guardar en localStorage
        localStorage.setItem('token', access_token);
        localStorage.setItem('user', JSON.stringify(user));
        
        // Actualizar estado
        this.token = access_token;
        this.user = user;
        
        return true;
      } catch (error) {
        this.error = error.response?.data?.message || 'Error al iniciar sesión';
        return false;
      } finally {
        this.loading = false;
      }
    },
    
    async register(userData) {
      this.loading = true;
      this.error = null;
      
      try {
        await apiClient.post('/auth/register', userData);
        return true;
      } catch (error) {
        this.error = error.response?.data?.message || 'Error al registrarse';
        return false;
      } finally {
        this.loading = false;
      }
    },
    
    logout() {
      // Eliminar de localStorage
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      
      // Resetear estado
      this.token = null;
      this.user = null;
    },
  },
});