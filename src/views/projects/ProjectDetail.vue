<template>
  <div>
    <div v-if="projectsStore.loading" class="text-center py-4">
      <p>Cargando proyecto...</p>
    </div>
    
    <div v-else-if="projectsStore.error" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
      {{ projectsStore.error }}
    </div>
    
    <div v-else-if="!project" class="card text-center py-8">
      <p class="text-lg mb-4">Proyecto no encontrado</p>
      <router-link to="/projects" class="btn">Volver a proyectos</router-link>
    </div>
    
    <div v-else>
      <div class="flex justify-between items-center mb-6">
        <div>
          <router-link to="/projects" class="text-blue-500 hover:text-blue-700 mb-2 inline-block">
            &larr; Volver a proyectos
          </router-link>
          <h1 class="text-2xl font-bold">{{ project.title }}</h1>
        </div>
        <div class="flex space-x-2">
          <button @click="showEditModal = true" class="btn bg-yellow-500 hover:bg-yellow-600">
            Editar Proyecto
          </button>
          <button @click="showCreateTaskModal = true" class="btn bg-green-500 hover:bg-green-600">
            Nueva Tarea
          </button>
        </div>
      </div>
      
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div class="md:col-span-2">
          <div class="card">
            <h2 class="text-xl font-semibold mb-4">Detalles del Proyecto</h2>
            <p><strong>Descripción:</strong> {{ project.description || 'Sin descripción' }}</p>
            <p class="mt-2"><strong>Estado:</strong> 
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
            </p>
            <p class="mt-2"><strong>Creado:</strong> {{ formatDate(project.createdAt) }}</p>
            <p class="mt-2"><strong>Última actualización:</strong> {{ formatDate(project.updatedAt) }}</p>
          </div>
        </div>
        <div>
          <div class="card">
            <h2 class="text-xl font-semibold mb-4">Resumen</h2>
            <p><strong>Total de tareas:</strong> {{ project.tasks ? project.tasks.length : 0 }}</p>
            <p class="mt-2"><strong>Pendientes:</strong> {{ countTasksByStatus('PENDING') }}</p>
            <p class="mt-2"><strong>En progreso:</strong> {{ countTasksByStatus('IN_PROGRESS') }}</p>
            <p class="mt-2"><strong>Completadas:</strong> {{ countTasksByStatus('COMPLETED') }}</p>
          </div>
        </div>
      </div>
      
      <div class="card">
        <h2 class="text-xl font-semibold mb-4">Tareas</h2>
        
        <div v-if="!project.tasks || project.tasks.length === 0" class="text-center py-4">
          <p class="mb-4">No hay tareas para este proyecto</p>
          <button @click="showCreateTaskModal = true" class="btn">Crear la primera tarea</button>
        </div>
        
        <div v-else class="overflow-x-auto">
          <table class="min-w-full">
            <thead>
              <tr class="bg-gray-100">
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Título</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Estado</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Prioridad</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Fecha límite</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Acciones</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="task in project.tasks" :key="task.id" class="hover:bg-gray-50">
                <td class="px-6 py-4 whitespace-nowrap">{{ task.title }}</td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span 
                    class="px-2 py-1 text-xs rounded" 
                    :class="{
                      'bg-yellow-100 text-yellow-800': task.status === 'PENDING',
                      'bg-blue-100 text-blue-800': task.status === 'IN_PROGRESS',
                      'bg-green-100 text-green-800': task.status === 'COMPLETED',
                    }"
                  >
                    {{ formatTaskStatus(task.status) }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span 
                    class="px-2 py-1 text-xs rounded" 
                    :class="{
                      'bg-green-100 text-green-800': task.priority === 'LOW',
                      'bg-yellow-100 text-yellow-800': task.priority === 'MEDIUM',
                      'bg-red-100 text-red-800': task.priority === 'HIGH',
                    }"
                  >
                    {{ formatPriority(task.priority) }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  {{ task.dueDate ? formatDate(task.dueDate) : 'Sin fecha' }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  <button 
                    @click="handleEditTask(task)" 
                    class="text-blue-600 hover:text-blue-900 mr-2"
                  >
                    Editar
                  </button>
                  <button 
                    @click="handleDeleteTask(task.id)" 
                    class="text-red-600 hover:text-red-900"
                  >
                    Eliminar
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    
    <!-- Modal para editar proyecto -->
    <div v-if="showEditModal && project" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
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
    
    <!-- Esto es solo un esqueleto básico, para el siguiente commit completaremos las vistas y modales restantes -->
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useProjectsStore } from '../../stores/projects';
import { useTasksStore } from '../../stores/tasks';

const route = useRoute();
const router = useRouter();
const projectsStore = useProjectsStore();
const tasksStore = useTasksStore();

const projectId = computed(() => route.params.id);
const project = computed(() => projectsStore.currentProject);

const showEditModal = ref(false);
const showCreateTaskModal = ref(false);
const editingProject = ref({});
const editingTask = ref(null);

onMounted(async () => {
  await projectsStore.fetchProjectById(projectId.value);
});

const formatStatus = (status) => {
  const statusMap = {
    'ACTIVE': 'Activo',
    'ON_HOLD': 'En pausa',
    'COMPLETED': 'Completado',
  };
  return statusMap[status] || status;
};

const formatTaskStatus = (status) => {
  const statusMap = {
    'PENDING': 'Pendiente',
    'IN_PROGRESS': 'En progreso',
    'COMPLETED': 'Completado',
  };
  return statusMap[status] || status;
};

const formatPriority = (priority) => {
  const priorityMap = {
    'LOW': 'Baja',
    'MEDIUM': 'Media',
    'HIGH': 'Alta',
  };
  return priorityMap[priority] || priority;
};

const formatDate = (dateString) => {
  const date = new Date(dateString);
  return date.toLocaleDateString();
};

const countTasksByStatus = (status) => {
  if (!project.value || !project.value.tasks) return 0;
  return project.value.tasks.filter(task => task.status === status).length;
};

const handleUpdateProject = async () => {
  await projectsStore.updateProject(projectId.value, editingProject.value);
  showEditModal.value = false;
};

const handleEditTask = (task) => {
  // Implementaremos esto en el siguiente commit
  console.log('Editar tarea:', task);
};

const handleDeleteTask = async (id) => {
  if (confirm('¿Estás seguro de que deseas eliminar esta tarea?')) {
    await tasksStore.deleteTask(id);
    // Recargar el proyecto para actualizar la lista de tareas
    await projectsStore.fetchProjectById(projectId.value);
  }
};
</script>