import { defineStore } from 'pinia';
import apiClient from '../services/api';

export const useTasksStore = defineStore('tasks', {
  state: () => ({
    tasks: [],
    projectTasks: {},
    loading: false,
    error: null,
  }),
  
  getters: {
    getTaskById: (state) => (id) => {
      return state.tasks.find(task => task.id === id);
    },
    
    getTasksByProject: (state) => (projectId) => {
      return state.projectTasks[projectId] || [];
    },
  },
  
  actions: {
    async fetchTasks() {
      this.loading = true;
      this.error = null;
      
      try {
        const response = await apiClient.get('/tasks');
        this.tasks = response.data;
      } catch (error) {
        this.error = error.response?.data?.message || 'Error al cargar tareas';
      } finally {
        this.loading = false;
      }
    },
    
    async fetchTasksByProject(projectId) {
      this.loading = true;
      this.error = null;
      
      try {
        const response = await apiClient.get(`/tasks/project/${projectId}`);
        this.projectTasks[projectId] = response.data;
        return response.data;
      } catch (error) {
        this.error = error.response?.data?.message || 'Error al cargar tareas del proyecto';
        return [];
      } finally {
        this.loading = false;
      }
    },
    
    async createTask(taskData) {
      this.loading = true;
      this.error = null;
      
      try {
        const response = await apiClient.post('/tasks', taskData);
        this.tasks.push(response.data);
        
        // Actualizar tareas del proyecto si ya existen
        const projectId = response.data.projectId;
        if (this.projectTasks[projectId]) {
          this.projectTasks[projectId].push(response.data);
        }
        
        return response.data;
      } catch (error) {
        this.error = error.response?.data?.message || 'Error al crear la tarea';
        return null;
      } finally {
        this.loading = false;
      }
    },
    
    async updateTask(id, taskData) {
      this.loading = true;
      this.error = null;
      
      try {
        const response = await apiClient.patch(`/tasks/${id}`, taskData);
        
        // Actualizar tarea en la lista general
        const index = this.tasks.findIndex(task => task.id === id);
        if (index !== -1) {
          this.tasks[index] = response.data;
        }
        
        // Actualizar tarea en la lista de proyecto
        const projectId = response.data.projectId;
        if (this.projectTasks[projectId]) {
          const projectIndex = this.projectTasks[projectId].findIndex(task => task.id === id);
          if (projectIndex !== -1) {
            this.projectTasks[projectId][projectIndex] = response.data;
          }
        }
        
        return response.data;
      } catch (error) {
        this.error = error.response?.data?.message || 'Error al actualizar la tarea';
        return null;
      } finally {
        this.loading = false;
      }
    },
    
    async deleteTask(id) {
      this.loading = true;
      this.error = null;
      
      try {
        const task = this.getTaskById(id);
        await apiClient.delete(`/tasks/${id}`);
        
        // Eliminar tarea de la lista general
        this.tasks = this.tasks.filter(task => task.id !== id);
        
        // Eliminar tarea de la lista de proyecto
        if (task) {
          const projectId = task.projectId;
          if (this.projectTasks[projectId]) {
            this.projectTasks[projectId] = this.projectTasks[projectId].filter(t => t.id !== id);
          }
        }
        
        return true;
      } catch (error) {
        this.error = error.response?.data?.message || 'Error al eliminar la tarea';
        return false;
      } finally {
        this.loading = false;
      }
    },
  },
});