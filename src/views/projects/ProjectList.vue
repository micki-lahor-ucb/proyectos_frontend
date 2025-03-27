<template>
  <div>
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-2xl font-bold">Mis Proyectos</h1>
      <button @click="showCreateModal = true" class="btn bg-green-500 hover:bg-green-600">
        Nuevo Proyecto
      </button>
    </div>
    
    <div v-if="projectsStore.loading" class="text-center py-4">
      <p>Cargando proyectos...</p>
    </div>
    
    <div v-else-if="projectsStore.error" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
      {{ projectsStore.error }}
    </div>
    
    <div v-else-if="projectsStore.projects.length === 0" class="card text-center py-8">
      <p class="text-lg mb-4">No tienes proyectos aún</p>
      <button @click="showCreateModal = true" class="btn">Crear tu primer proyecto</button>
    </div>
    
    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div v-for="project in projectsStore.projects" :key="project.id" class="card hover:shadow-lg transition-shadow">
        <div class="flex justify-between items-start">
          <h2 class="text-xl font-semibold mb-2">{{ project.title }}</h2>
          <span 
            class="px-2 py-1 text-xs rounded" 
            :class="{
              'bg-green-100 text-green-800': project.status === 'ACTIVE',
              'bg-yellow-100 text-yellow-800': project.status === 'ON_HOLD',
              'bg-blue-100 text-blue-800': project.status === 'COMPLETED',
            }"
          >
            {{ formatStatus(project.status) }}
          </span>
        </div>
        
        <p class="text-gray-600 mb-4">{{ project.description || 'Sin descripción' }}</p>
        
        <div class="text-sm text-gray-500 mb-4">
          <p>Tareas: {{ project.tasks ? project.tasks.length : 0 }}</p>
          <p>Creado: {{ formatDate(project.createdAt) }}</p>
        </div>
        
        <div class="flex justify-between">
          <router-link :to="`/projects/${project.id}`" class="btn">Ver detalles</router-link>
          <button @click="handleDeleteProject(project.id)" class="btn-danger">Eliminar</button>
        </div>
      </div>
    </div>
    
    <!-- Modal para crear proyecto -->
    <div v-if="showCreateModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h2 class="text-xl font-bold mb-4">Crear Nuevo Proyecto</h2>
        
        <form @submit.prevent="handleCreateProject">
          <div class="form-group">
            <label for="title" class="form-label">Título</label>
            <input
              id="title"
              v-model="newProject.title"
              type="text"
              class="input w-full"
              required
            />
          </div>
          
          <div class="form-group">
            <label for="description" class="form-label">Descripción</label>
            <textarea
              id="description"
              v-model="newProject.description"
              class="input w-full"
              rows="3"
            ></textarea>
          </div>
          
          <div class="flex justify-end mt-6 space-x-2">
            <button 
              type="button" 
              @click="showCreateModal = false" 
              class="px-4 py-2 bg-gray-200 text-gray-800 rounded hover:bg-gray-300"
            >
              Cancelar
            </button>
            <button 
              type="submit" 
              class="btn"
              :disabled="projectsStore.loading"
            >
              {{ projectsStore.loading ? 'Creando...' : 'Crear Proyecto' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useProjectsStore } from '../../stores/projects';

const projectsStore = useProjectsStore();

const showCreateModal = ref(false);
const newProject = ref({
  title: '',
  description: '',
  status: 'ACTIVE',
});

onMounted(async () => {
  await projectsStore.fetchProjects();
});

const formatStatus = (status) => {
  const statusMap = {
    'ACTIVE': 'Activo',
    'ON_HOLD': 'En pausa',
    'COMPLETED': 'Completado',
  };
  return statusMap[status] || status;
};

const formatDate = (dateString) => {
  const date = new Date(dateString);
  return date.toLocaleDateString();
};

const handleCreateProject = async () => {
  await projectsStore.createProject(newProject.value);
  showCreateModal.value = false;
  newProject.value = {
    title: '',
    description: '',
    status: 'ACTIVE',
  };
};

const handleDeleteProject = async (id) => {
  if (confirm('¿Estás seguro de que deseas eliminar este proyecto?')) {
    await projectsStore.deleteProject(id);
  }
};
</script>