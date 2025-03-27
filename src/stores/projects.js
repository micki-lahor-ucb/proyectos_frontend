import { defineStore } from 'pinia';
import apiClient from '../services/api';

export const useProjectsStore = defineStore('projects', {
  state: () => ({
    projects: [],
    currentProject: null,
    loading: false,
    error: null,
  }),
  
  getters: {
    getProjectById: (state) => (id) => {
      return state.projects.find(project => project.id === id);
    },
  },
  
  actions: {
    async fetchProjects() {
      this.loading = true;
      this.error = null;
      
      try {
        const response = await apiClient.get('/projects');
        this.projects = response.data;
      } catch (error) {
        this.error = error.response?.data?.message || 'Error al cargar proyectos';
      } finally {
        this.loading = false;
      }
    },
    
    async fetchProjectById(id) {
      this.loading = true;
      this.error = null;
      
      try {
        const response = await apiClient.get(`/projects/${id}`);
        this.currentProject = response.data;
        return response.data;
      } catch (error) {
        this.error = error.response?.data?.message || 'Error al cargar el proyecto';
        return null;
      } finally {
        this.loading = false;
      }
    },
    
    async createProject(projectData) {
      this.loading = true;
      this.error = null;
      
      try {
        const response = await apiClient.post('/projects', projectData);
        this.projects.push(response.data);
        return response.data;
      } catch (error) {
        this.error = error.response?.data?.message || 'Error al crear el proyecto';
        return null;
      } finally {
        this.loading = false;
      }
    },
    
    async updateProject(id, projectData) {
      this.loading = true;
      this.error = null;
      
      try {
        const response = await apiClient.patch(`/projects/${id}`, projectData);
        
        // Actualizar proyecto en la lista
        const index = this.projects.findIndex(project => project.id === id);
        if (index !== -1) {
          this.projects[index] = response.data;
        }
        
        // Actualizar proyecto actual si es el mismo
        if (this.currentProject && this.currentProject.id === id) {
          this.currentProject = response.data;
        }
        
        return response.data;
      } catch (error) {
        this.error = error.response?.data?.message || 'Error al actualizar el proyecto';
        return null;
      } finally {
        this.loading = false;
      }
    },
    
    async deleteProject(id) {
      this.loading = true;
      this.error = null;
      
      try {
        await apiClient.delete(`/projects/${id}`);
        
        // Eliminar proyecto de la lista
        this.projects = this.projects.filter(project => project.id !== id);
        
        // Resetear proyecto actual si es el mismo
        if (this.currentProject && this.currentProject.id === id) {
          this.currentProject = null;
        }
        
        return true;
      } catch (error) {
        this.error = error.response?.data?.message || 'Error al eliminar el proyecto';
        return false;
      } finally {
        this.loading = false;
      }
    },
  },
});