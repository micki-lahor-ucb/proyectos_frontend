<template>
  <div>
    <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 gap-4">
      <div>
        <h1 class="text-2xl font-bold">Mis Tareas</h1>
        <p class="text-gray-600">Gestiona todas tus tareas en un solo lugar</p>
      </div>
      
      <div class="flex flex-col sm:flex-row gap-2">
        <button @click="showCreateModal = true" class="btn bg-green-500 hover:bg-green-600">
          Nueva Tarea
        </button>
      </div>
    </div>
    
    <!-- Panel de filtros -->
    <div class="card mb-6">
      <h2 class="text-lg font-semibold mb-4">Filtros</h2>
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div>
          <label for="search" class="form-label">Buscar</label>
          <div class="relative">
            <input 
              id="search"
              v-model="filters.search" 
              type="text" 
              placeholder="Buscar tareas..." 
              class="input w-full pr-8"
            />
            <span class="absolute right-2 top-2.5 text-gray-400">
              🔍
            </span>
          </div>
        </div>
        
        <div>
          <label for="status-filter" class="form-label">Estado</label>
          <select
            id="status-filter"
            v-model="filters.status"
            class="input w-full"
          >
            <option value="">Todos los estados</option>
            <option value="PENDING">Pendientes</option>
            <option value="IN_PROGRESS">En progreso</option>
            <option value="COMPLETED">Completados</option>
          </select>
        </div>
        
        <div>
          <label for="priority-filter" class="form-label">Prioridad</label>
          <select
            id="priority-filter"
            v-model="filters.priority"
            class="input w-full"
          >
            <option value="">Todas las prioridades</option>
            <option value="LOW">Baja</option>
            <option value="MEDIUM">Media</option>
            <option value="HIGH">Alta</option>
          </select>
        </div>
        
        <div>
          <label for="project-filter" class="form-label">Proyecto</label>
          <select
            id="project-filter"
            v-model="filters.projectId"
            class="input w-full"
          >
            <option value="">Todos los proyectos</option>
            <option v-for="project in projectsStore.projects" :key="project.id" :value="project.id">
              {{ project.title }}
            </option>
          </select>
        </div>
      </div>
      
      <div class="flex justify-between mt-4">
        <div class="text-sm text-gray-500">
          Mostrando {{ filteredTasks.length }} de {{ tasksStore.tasks.length }} tareas
        </div>
        
        <div class="flex gap-2">
          <label for="sort-by" class="text-sm self-center">Ordenar por:</label>
          <select
            id="sort-by"
            v-model="sortBy"
            class="input text-sm py-1"
          >
            <option value="dueDate">Fecha límite</option>
            <option value="priority">Prioridad</option>
            <option value="status">Estado</option>
            <option value="title">Título</option>
          </select>
          <button 
            @click="sortDirection = sortDirection === 'asc' ? 'desc' : 'asc'" 
            class="btn text-sm py-1"
          >
            {{ sortDirection === 'asc' ? '↑' : '↓' }}
          </button>
          <button 
            @click="clearFilters" 
            class="px-3 py-1 bg-gray-200 text-gray-800 rounded hover:bg-gray-300 text-sm"
          >
            Limpiar filtros
          </button>
        </div>
      </div>
    </div>
    
    <!-- Panel de estadísticas -->
    <div class="card mb-6">
      <h2 class="text-lg font-semibold mb-4">Resumen</h2>
      <div class="grid grid-cols-2 md:grid-cols-5 gap-4 text-center">
        <div class="bg-gray-50 p-3 rounded">
          <p class="font-bold text-2xl">{{ tasksStore.tasks.length }}</p>
          <p class="text-sm text-gray-600">Total</p>
        </div>
        <div class="bg-yellow-50 p-3 rounded">
          <p class="font-bold text-2xl">{{ countTasksByStatus('PENDING') }}</p>
          <p class="text-sm text-gray-600">Pendientes</p>
        </div>
        <div class="bg-blue-50 p-3 rounded">
          <p class="font-bold text-2xl">{{ countTasksByStatus('IN_PROGRESS') }}</p>
          <p class="text-sm text-gray-600">En progreso</p>
        </div>
        <div class="bg-green-50 p-3 rounded">
          <p class="font-bold text-2xl">{{ countTasksByStatus('COMPLETED') }}</p>
          <p class="text-sm text-gray-600">Completadas</p>
        </div>
        <div class="bg-red-50 p-3 rounded">
          <p class="font-bold text-2xl">{{ countHighPriorityTasks() }}</p>
          <p class="text-sm text-gray-600">Alta prioridad</p>
        </div>
      </div>
      
      <div class="mt-4">
        <div class="flex justify-between text-xs mb-1">
          <span>Progreso general</span>
          <span>{{ completionPercentage }}%</span>
        </div>
        <div class="w-full bg-gray-200 rounded-full h-2.5">
          <div 
            class="bg-blue-600 h-2.5 rounded-full" 
            :style="{ width: `${completionPercentage}%` }"
          ></div>
        </div>
      </div>
    </div>
    
    <!-- Loading y error states -->
    <div v-if="tasksStore.loading" class="text-center py-4">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      <p class="mt-2">Cargando tareas...</p>
    </div>
    
    <div v-else-if="tasksStore.error" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
      {{ tasksStore.error }}
    </div>
    
    <div v-else-if="tasksStore.tasks.length === 0" class="card text-center py-8">
      <p class="text-lg mb-4">No tienes tareas aún</p>
      <button @click="showCreateModal = true" class="btn">Crear tu primera tarea</button>
    </div>
    
    <div v-else-if="filteredTasks.length === 0" class="card text-center py-8">
      <p class="text-lg mb-4">No se encontraron tareas que coincidan con tus filtros</p>
      <button @click="clearFilters" class="btn">Limpiar filtros</button>
    </div>
    
    <!-- Vista de tareas (por tarjetas y por tabla) -->
    <div v-else>
      <div class="mb-4 flex justify-end">
        <button 
          @click="viewMode = 'cards'" 
          class="px-3 py-1 rounded" 
          :class="viewMode === 'cards' ? 'bg-blue-500 text-white' : 'bg-gray-200'"
        >
          Tarjetas
        </button>
        <button 
          @click="viewMode = 'table'" 
          class="px-3 py-1 rounded ml-2" 
          :class="viewMode === 'table' ? 'bg-blue-500 text-white' : 'bg-gray-200'"
        >
          Tabla
        </button>
      </div>
      
      <!-- Vista de tarjetas -->
      <div v-if="viewMode === 'cards'" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <TaskCard 
          v-for="task in sortedTasks" 
          :key="task.id" 
          :task="task"
          @edit="openEditModal"
          @delete="handleDeleteTask"
          @complete="markTaskAsCompleted"
        />
      </div>
      
      <!-- Vista de tabla -->
      <div v-else class="card">
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
              <tr v-for="task in sortedTasks" :key="task.id" class="hover:bg-gray-50">
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="font-medium text-gray-900">{{ task.title }}</div>
                  <div v-if="task.description" class="text-sm text-gray-500 truncate max-w-xs">
                    {{ task.description }}
                  </div>
                </td>
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
                <td class="px-6 py-4 whitespace-nowrap" :class="{ 'text-red-500': isOverdue(task) }">
                  {{ task.dueDate ? formatDate(task.dueDate) : 'Sin fecha' }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                  <div class="flex gap-2">
                    <button 
                      @click="openEditModal(task)" 
                      class="text-blue-600 hover:text-blue-900"
                    >
                      Editar
                    </button>
                    <button 
                      @click="handleDeleteTask(task.id)" 
                      class="text-red-600 hover:text-red-900"
                    >
                      Eliminar
                    </button>
                    <button 
                      v-if="task.status !== 'COMPLETED'"
                      @click="markTaskAsCompleted(task.id)" 
                      class="text-green-600 hover:text-green-900"
                    >
                      Completar
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    
    <!-- Modales para crear y editar tareas (mantener los que ya teníamos) -->
    <!-- ... -->
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useTasksStore } from '../../stores/tasks';
import { useProjectsStore } from '../../stores/projects';
import { useNotification } from '../../composables/useNotification';
import TaskCard from '../../components/TaskCard.vue';

const tasksStore = useTasksStore();
const projectsStore = useProjectsStore();
const { notify } = useNotification();

// Estado para modales
const showCreateModal = ref(false);
const showEditModal = ref(false);
const editingTask = ref(null);
const newTask = ref({
  title: '',
  description: '',
  status: 'PENDING',
  priority: 'MEDIUM',
  dueDate: '',
  projectId: '',
});

// Estado para filtros y ordenación
const filters = ref({
  search: '',
  status: '',
  priority: '',
  projectId: '',
});

const sortBy = ref('dueDate');
const sortDirection = ref('asc');
const viewMode = ref('cards'); // 'cards' o 'table'

// Cargar datos al montar el componente
onMounted(async () => {
  try {
    await Promise.all([
      tasksStore.fetchTasks(),
      projectsStore.fetchProjects()
    ]);
  } catch (error) {
    notify('Error al cargar las tareas', 'error');
  }
});

// Filtrar tareas
const filteredTasks = computed(() => {
  let result = [...tasksStore.tasks];
  
  // Filtrar por búsqueda
  if (filters.value.search) {
    const query = filters.value.search.toLowerCase();
    result = result.filter(task => 
      task.title.toLowerCase().includes(query) || 
      (task.description && task.description.toLowerCase().includes(query))
    );
  }
  
  // Filtrar por estado
  if (filters.value.status) {
    result = result.filter(task => task.status === filters.value.status);
  }
  
  // Filtrar por prioridad
  if (filters.value.priority) {
    result = result.filter(task => task.priority === filters.value.priority);
  }
  
  // Filtrar por proyecto
  if (filters.value.projectId) {
    result = result.filter(task => task.projectId === filters.value.projectId);
  }
  
  return result;
});

// Ordenar tareas
const sortedTasks = computed(() => {
  return [...filteredTasks.value].sort((a, b) => {
    let valueA, valueB;
    
    // Determinar los valores a comparar según el campo de ordenación
    switch (sortBy.value) {
      case 'dueDate':
        valueA = a.dueDate ? new Date(a.dueDate).getTime() : Number.MAX_SAFE_INTEGER;
        valueB = b.dueDate ? new Date(b.dueDate).getTime() : Number.MAX_SAFE_INTEGER;
        break;
      case 'priority':
        const priorityValues = { 'HIGH': 3, 'MEDIUM': 2, 'LOW': 1 };
        valueA = priorityValues[a.priority] || 0;
        valueB = priorityValues[b.priority] || 0;
        break;
      case 'status':
        const statusValues = { 'PENDING': 3, 'IN_PROGRESS': 2, 'COMPLETED': 1 };
        valueA = statusValues[a.status] || 0;
        valueB = statusValues[b.status] || 0;
        break;
      default:
        valueA = a[sortBy.value] || '';
        valueB = b[sortBy.value] || '';
    }
    
    // Comparar y aplicar la dirección de ordenación
    if (valueA < valueB) return sortDirection.value === 'asc' ? -1 : 1;
    if (valueA > valueB) return sortDirection.value === 'asc' ? 1 : -1;
    return 0;
  });
});

// Estadísticas
const countTasksByStatus = (status) => {
  return tasksStore.tasks.filter(task => task.status === status).length;
};

const countHighPriorityTasks = () => {
  return tasksStore.tasks.filter(task => task.priority === 'HIGH').length;
};

const completionPercentage = computed(() => {
  if (tasksStore.tasks.length === 0) return 0;
  const completedTasks = countTasksByStatus('COMPLETED');
  return Math.round((completedTasks / tasksStore.tasks.length) * 100);
});

// Funciones de formato
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
  if (!dateString) return 'Sin fecha';
  const date = new Date(dateString);
  return date.toLocaleDateString();
};

const isOverdue = (task) => {
  if (!task.dueDate) return false;
  const dueDate = new Date(task.dueDate);
  const today = new Date();
  return dueDate < today && task.status !== 'COMPLETED';
};

// Limpiar filtros
const clearFilters = () => {
  filters.value = {
    search: '',
    status: '',
    priority: '',
    projectId: '',
  };
};

// Manipulación de tareas
const handleCreateTask = async () => {
  try {
    await tasksStore.createTask(newTask.value);
    showCreateModal.value = false;
    
    // Reiniciar el formulario
    newTask.value = {
      title: '',
      description: '',
      status: 'PENDING',
      priority: 'MEDIUM',
      dueDate: '',
      projectId: '',
    };
    
    notify('Tarea creada con éxito', 'success');
  } catch (error) {
    notify('Error al crear la tarea', 'error');
  }
};

const openEditModal = (task) => {
  // Convertir la fecha a formato YYYY-MM-DD para el input type="date"
  let taskCopy = { ...task };
  if (taskCopy.dueDate) {
    const date = new Date(taskCopy.dueDate);
    taskCopy.dueDate = date.toISOString().split('T')[0];
  }
  
  editingTask.value = taskCopy;
  showEditModal.value = true;
};

const handleUpdateTask = async () => {
  try {
    await tasksStore.updateTask(editingTask.value.id, editingTask.value);
    showEditModal.value = false;
    notify('Tarea actualizada con éxito', 'success');
  } catch (error) {
    notify('Error al actualizar la tarea', 'error');
  }
};

const handleDeleteTask = async (id) => {
  if (confirm('¿Estás seguro de que deseas eliminar esta tarea?')) {
    try {
      await tasksStore.deleteTask(id);
      notify('Tarea eliminada con éxito', 'success');
    } catch (error) {
      notify('Error al eliminar la tarea', 'error');
    }
  }
};

const markTaskAsCompleted = async (id) => {
  try {
    const task = tasksStore.tasks.find(t => t.id === id);
    if (task) {
      await tasksStore.updateTask(id, { ...task, status: 'COMPLETED' });
      notify('Tarea marcada como completada', 'success');
    }
  } catch (error) {
    notify('Error al actualizar la tarea', 'error');
  }
};
</script>