<template>
  <div>
    <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 gap-4">
      <div>
        <h1 class="text-2xl font-bold">Mis Proyectos</h1>
        <p class="text-gray-600">Gestiona tus proyectos y tareas</p>
      </div>
      
      <div class="flex flex-col sm:flex-row gap-2">
        <div class="relative">
          <input 
            v-model="searchQuery" 
            type="text" 
            placeholder="Buscar proyectos..." 
            class="input pr-8"
          />
          <span class="absolute right-2 top-2.5 text-gray-400">
            🔍
          </span>
        </div>
        
        <select v-model="statusFilter" class="input">
          <option value="">Todos los estados</option>
          <option value="ACTIVE">Activo</option>
          <option value="ON_HOLD">En pausa</option>
          <option value="COMPLETED">Completado</option>
        </select>
        
        <button @click="showCreateModal = true" class="btn bg-green-500 hover:bg-green-600">
          Nuevo Proyecto
        </button>
      </div>
    </div>
    
    <!-- Loading and error states -->
    <div v-if="projectsStore.loading" class="text-center py-4">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      <p class="mt-2">Cargando proyectos...</p>
    </div>
    
    <div v-else-if="projectsStore.error" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
      {{ projectsStore.error }}
    </div>
    
    <div v-else-if="projectsStore.projects.length === 0" class="card text-center py-8">
      <p class="text-lg mb-4">No tienes proyectos aún</p>
      <button @click="showCreateModal = true" class="btn">Crear tu primer proyecto</button>
    </div>
    
    <!-- En caso de que haya proyectos pero ninguno coincida con los filtros -->
    <div v-else-if="filteredProjects.length === 0" class="card text-center py-8">
      <p class="text-lg mb-4">No se encontraron proyectos que coincidan con tu búsqueda</p>
      <button @click="clearFilters" class="btn">Limpiar filtros</button>
    </div>
    
    <!-- Grid de proyectos -->
    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <ProjectCard 
        v-for="project in filteredProjects" 
        :key="project.id" 
        :project="project"
        @edit="openEditModal"
        @delete="handleDeleteProject"
      />
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
          
          <div class="form-group">
            <label for="status" class="form-label">Estado</label>
            <select
              id="status"
              v-model="newProject.status"
              class="input w-full"
            >
              <option value="ACTIVE">Activo</option>
              <option value="ON_HOLD">En pausa</option>
              <option value="COMPLETED">Completado</option>
            </select>
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
    
    <!-- Modal para editar proyecto -->
    <div v-if="showEditModal && editingProject" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h2 class="text-xl font-bold mb-4">Editar Proyecto</h2>
        
        <form @submit.prevent="handleUpdateProject">
          <div class="form-group">
            <label for="edit-title" class="form-label">Título</label>
            <input
              id="edit-title"
              v-model="editingProject.title"
              type="text"
              class="input w-full"
              required
            />
          </div>
          
          <div class="form-group">
            <label for="edit-description" class="form-label">Descripción</label>
            <textarea
              id="edit-description"
              v-model="editingProject.description"
              class="input w-full"
              rows="3"
            ></textarea>
          </div>
          
          <div class="form-group">
            <label for="edit-status" class="form-label">Estado</label>
            <select
              id="edit-status"
              v-model="editingProject.status"
              class="input w-full"
            >
              <option value="ACTIVE">Activo</option>
              <option value="ON_HOLD">En pausa</option>
              <option value="COMPLETED">Completado</option>
            </select>
          </div>
          
          <div class="flex justify-end mt-6 space-x-2">
            <button 
              type="button" 
              @click="showEditModal = false" 
              class="px-4 py-2 bg-gray-200 text-gray-800 rounded hover:bg-gray-300"
            >
              Cancelar
            </button>
            <button 
              type="submit" 
              class="btn"
              :disabled="projectsStore.loading"
            >
              {{ projectsStore.loading ? 'Guardando...' : 'Guardar Cambios' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useProjectsStore } from '../../stores/projects';
import { useNotification } from '../../composables/useNotification';
import ProjectCard from '../../components/ProjectCard.vue';

const projectsStore = useProjectsStore();
const { notify } = useNotification();

// Estado para filtros y búsqueda
const searchQuery = ref('');
const statusFilter = ref('');

// Estado para modales
const showCreateModal = ref(false);
const showEditModal = ref(false);
const editingProject = ref(null);
const newProject = ref({
  title: '',
  description: '',
  status: 'ACTIVE',
});

// Cargar proyectos al montar el componente
onMounted(async () => {
  try {
    await projectsStore.fetchProjects();
  } catch (error) {
    notify('Error al cargar los proyectos', 'error');
  }
});

// Filtrar proyectos
const filteredProjects = computed(() => {
  let result = [...projectsStore.projects];
  
  // Filtrar por estado
  if (statusFilter.value) {
    result = result.filter(project => project.status === statusFilter.value);
  }
  
  // Filtrar por búsqueda
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase();
    result = result.filter(project => 
      project.title.toLowerCase().includes(query) || 
      (project.description && project.description.toLowerCase().includes(query))
    );
  }
  
  return result;
});

// Limpiar filtros
const clearFilters = () => {
  searchQuery.value = '';
  statusFilter.value = '';
};

// Abrir modal de edición
const openEditModal = (project) => {
  editingProject.value = { ...project };
  showEditModal.value = true;
};

// Crear proyecto
const handleCreateProject = async () => {
  try {
    await projectsStore.createProject(newProject.value);
    showCreateModal.value = false;
    newProject.value = {
      title: '',
      description: '',
      status: 'ACTIVE',
    };
    notify('Proyecto creado con éxito', 'success');
  } catch (error) {
    notify('Error al crear el proyecto', 'error');
  }
};

// Actualizar proyecto
const handleUpdateProject = async () => {
  try {
    await projectsStore.updateProject(editingProject.value.id, editingProject.value);
    showEditModal.value = false;
    notify('Proyecto actualizado con éxito', 'success');
  } catch (error) {
    notify('Error al actualizar el proyecto', 'error');
  }
};

// Eliminar proyecto
const handleDeleteProject = async (id) => {
  if (confirm('¿Estás seguro de que deseas eliminar este proyecto? Esta acción eliminará también todas las tareas asociadas.')) {
    try {
      await projectsStore.deleteProject(id);
      notify('Proyecto eliminado con éxito', 'success');
    } catch (error) {
      notify('Error al eliminar el proyecto', 'error');
    }
  }
};
</script>