<template>
  <div>
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-2xl font-bold">Mis Tareas</h1>
      <button @click="showCreateModal = true" class="btn bg-green-500 hover:bg-green-600">
        Nueva Tarea
      </button>
    </div>
    
    <div v-if="tasksStore.loading" class="text-center py-4">
      <p>Cargando tareas...</p>
    </div>
    
    <div v-else-if="tasksStore.error" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
      {{ tasksStore.error }}
    </div>
    
    <div v-else-if="tasksStore.tasks.length === 0" class="card text-center py-8">
      <p class="text-lg mb-4">No tienes tareas aún</p>
      <button @click="showCreateModal = true" class="btn">Crear tu primera tarea</button>
    </div>
    
    <div v-else class="card">
      <div class="mb-4">
        <label for="filter-status" class="form-label inline-block mr-2">Filtrar por estado:</label>
        <select
          id="filter-status"
          v-model="filters.status"
          class="input"
        >
          <option value="">Todos</option>
          <option value="PENDING">Pendiente</option>
          <option value="IN_PROGRESS">En progreso</option>
          <option value="COMPLETED">Completado</option>
        </select>
      </div>
      
      <div class="overflow-x-auto">
        <table class="min-w-full">
          <thead>
            <tr class="bg-gray-100">
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Título</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Proyecto</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Estado</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Prioridad</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Fecha límite</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Acciones</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="task in filteredTasks" :key="task.id" class="hover:bg-gray-50">
              <td class="px-6 py-4 whitespace-nowrap">{{ task.title }}</td>
              <td class="px-6 py-4 whitespace-nowrap">
                <router-link :to="`/projects/${task.project?.id}`" class="text-blue-500 hover:text-blue-700">
                  {{ task.project?.title || 'Desconocido' }}
                </router-link>
              </td>
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
                  @click="openEditModal(task)" 
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
    
    <!-- Los modales para crear y editar tareas los implementaremos en el siguiente commit -->
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useTasksStore } from '../../stores/tasks';
import { useProjectsStore } from '../../stores/projects';

const tasksStore = useTasksStore();
const projectsStore = useProjectsStore();

const showCreateModal = ref(false);
const showEditModal = ref(false);
const editingTask = ref(null);

const filters = ref({
  status: '',
});

onMounted(async () => {
  await Promise.all([
    tasksStore.fetchTasks(),
    projectsStore.fetchProjects()
  ]);
});

const filteredTasks = computed(() => {
  if (!filters.value.status) return tasksStore.tasks;
  return tasksStore.tasks.filter(task => task.status === filters.value.status);
});

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

const openEditModal = (task) => {
  editingTask.value = { ...task };
  showEditModal.value = true;
};

const handleDeleteTask = async (id) => {
  if (confirm('¿Estás seguro de que deseas eliminar esta tarea?')) {
    await tasksStore.deleteTask(id);
  }
};
</script>