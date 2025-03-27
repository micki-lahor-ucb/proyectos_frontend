<template>
  <div>
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-2xl font-bold">Mis Tareas</h1>
      <button
        @click="showCreateModal = true"
        class="btn bg-green-500 hover:bg-green-600"
      >
        Nueva Tarea
      </button>
    </div>

    <div v-if="tasksStore.loading" class="text-center py-4">
      <p>Cargando tareas...</p>
    </div>

    <div
      v-else-if="tasksStore.error"
      class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4"
    >
      {{ tasksStore.error }}
    </div>

    <div
      v-else-if="tasksStore.tasks.length === 0"
      class="card text-center py-8"
    >
      <p class="text-lg mb-4">No tienes tareas aún</p>
      <button @click="showCreateModal = true" class="btn">
        Crear tu primera tarea
      </button>
    </div>

    <div v-else class="card">
      <div class="mb-4">
        <label for="filter-status" class="form-label inline-block mr-2"
          >Filtrar por estado:</label
        >
        <select id="filter-status" v-model="filters.status" class="input">
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
              <th
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                Título
              </th>
              <th
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                Proyecto
              </th>
              <th
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                Estado
              </th>
              <th
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                Prioridad
              </th>
              <th
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                Fecha límite
              </th>
              <th
                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
              >
                Acciones
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr
              v-for="task in filteredTasks"
              :key="task.id"
              class="hover:bg-gray-50"
            >
              <td class="px-6 py-4 whitespace-nowrap">{{ task.title }}</td>
              <td class="px-6 py-4 whitespace-nowrap">
                <router-link
                  :to="`/projects/${task.project?.id}`"
                  class="text-blue-500 hover:text-blue-700"
                >
                  {{ task.project?.title || "Desconocido" }}
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
                {{ task.dueDate ? formatDate(task.dueDate) : "Sin fecha" }}
              </td>
              <td
                class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium"
              >
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

    <!-- Modal para crear tarea -->
    <div
      v-if="showCreateModal"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
    >
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h2 class="text-xl font-bold mb-4">Crear Nueva Tarea</h2>

        <form @submit.prevent="handleCreateTask">
          <div class="form-group">
            <label for="task-title" class="form-label">Título</label>
            <input
              id="task-title"
              v-model="newTask.title"
              type="text"
              class="input w-full"
              required
            />
          </div>

          <div class="form-group">
            <label for="task-description" class="form-label">Descripción</label>
            <textarea
              id="task-description"
              v-model="newTask.description"
              class="input w-full"
              rows="3"
            ></textarea>
          </div>

          <div class="form-group">
            <label for="task-project" class="form-label">Proyecto</label>
            <select
              id="task-project"
              v-model="newTask.projectId"
              class="input w-full"
              required
            >
              <option value="">Seleccionar proyecto</option>
              <option
                v-for="project in projectsStore.projects"
                :key="project.id"
                :value="project.id"
              >
                {{ project.title }}
              </option>
            </select>
          </div>

          <div class="form-group">
            <label for="task-status" class="form-label">Estado</label>
            <select
              id="task-status"
              v-model="newTask.status"
              class="input w-full"
            >
              <option value="PENDING">Pendiente</option>
              <option value="IN_PROGRESS">En progreso</option>
              <option value="COMPLETED">Completado</option>
            </select>
          </div>

          <div class="form-group">
            <label for="task-priority" class="form-label">Prioridad</label>
            <select
              id="task-priority"
              v-model="newTask.priority"
              class="input w-full"
            >
              <option value="LOW">Baja</option>
              <option value="MEDIUM">Media</option>
              <option value="HIGH">Alta</option>
            </select>
          </div>

          <div class="form-group">
            <label for="task-due-date" class="form-label">Fecha límite</label>
            <input
              id="task-due-date"
              v-model="newTask.dueDate"
              type="date"
              class="input w-full"
            />
          </div>

          <div class="flex justify-end mt-6 space-x-2">
            <button
              type="button"
              @click="showCreateModal = false"
              class="px-4 py-2 bg-gray-200 text-gray-800 rounded hover:bg-gray-300"
            >
              Cancelar
            </button>
            <button type="submit" class="btn" :disabled="tasksStore.loading">
              {{ tasksStore.loading ? "Creando..." : "Crear Tarea" }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal para editar tarea -->
    <div
      v-if="showEditModal && editingTask"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
    >
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h2 class="text-xl font-bold mb-4">Editar Tarea</h2>

        <form @submit.prevent="handleUpdateTask">
          <div class="form-group">
            <label for="edit-task-title" class="form-label">Título</label>
            <input
              id="edit-task-title"
              v-model="editingTask.title"
              type="text"
              class="input w-full"
              required
            />
          </div>

          <div class="form-group">
            <label for="edit-task-description" class="form-label"
              >Descripción</label
            >
            <textarea
              id="edit-task-description"
              v-model="editingTask.description"
              class="input w-full"
              rows="3"
            ></textarea>
          </div>

          <div class="form-group">
            <label for="edit-task-project" class="form-label">Proyecto</label>
            <select
              id="edit-task-project"
              v-model="editingTask.projectId"
              class="input w-full"
              required
            >
              <option
                v-for="project in projectsStore.projects"
                :key="project.id"
                :value="project.id"
              >
                {{ project.title }}
              </option>
            </select>
          </div>

          <div class="form-group">
            <label for="edit-task-status" class="form-label">Estado</label>
            <select
              id="edit-task-status"
              v-model="editingTask.status"
              class="input w-full"
            >
              <option value="PENDING">Pendiente</option>
              <option value="IN_PROGRESS">En progreso</option>
              <option value="COMPLETED">Completado</option>
            </select>
          </div>

          <div class="form-group">
            <label for="edit-task-priority" class="form-label">Prioridad</label>
            <select
              id="edit-task-priority"
              v-model="editingTask.priority"
              class="input w-full"
            >
              <option value="LOW">Baja</option>
              <option value="MEDIUM">Media</option>
              <option value="HIGH">Alta</option>
            </select>
          </div>

          <div class="form-group">
            <label for="edit-task-due-date" class="form-label"
              >Fecha límite</label
            >
            <input
              id="edit-task-due-date"
              v-model="editingTask.dueDate"
              type="date"
              class="input w-full"
            />
          </div>

          <div class="flex justify-end mt-6 space-x-2">
            <button
              type="button"
              @click="showEditModal = false"
              class="px-4 py-2 bg-gray-200 text-gray-800 rounded hover:bg-gray-300"
            >
              Cancelar
            </button>
            <button type="submit" class="btn" :disabled="tasksStore.loading">
              {{ tasksStore.loading ? "Guardando..." : "Guardar Cambios" }}
            </button>
          </div>
        </form>
      </div>
    </div>
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
const newTask = ref({
  title: '',
  description: '',
  status: 'PENDING',
  priority: 'MEDIUM',
  dueDate: '',
  projectId: '',
});

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
  if (!dateString) return 'Sin fecha';
  const date = new Date(dateString);
  return date.toLocaleDateString();
};

const handleCreateTask = async () => {
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
  await tasksStore.updateTask(editingTask.value.id, editingTask.value);
  showEditModal.value = false;
};

const handleDeleteTask = async (id) => {
  if (confirm('¿Estás seguro de que deseas eliminar esta tarea?')) {
    await tasksStore.deleteTask(id);
  }
};
</script>
