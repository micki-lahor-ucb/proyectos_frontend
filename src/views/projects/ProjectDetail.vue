<template>
  <div>
    <!-- Loading and error states -->
    <div v-if="projectsStore.loading" class="text-center py-4">
      <div
        class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"
      ></div>
      <p class="mt-2">Cargando proyecto...</p>
    </div>

    <div
      v-else-if="projectsStore.error"
      class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4"
    >
      {{ projectsStore.error }}
    </div>

    <div v-else-if="!project" class="card text-center py-8">
      <p class="text-lg mb-4">Proyecto no encontrado</p>
      <router-link to="/projects" class="btn">Volver a proyectos</router-link>
    </div>

    <div v-else>
      <!-- Navegación y encabezado -->
      <div
        class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-6 gap-4"
      >
        <div>
          <router-link
            to="/projects"
            class="text-blue-500 hover:text-blue-700 mb-2 inline-block"
          >
            &larr; Volver a proyectos
          </router-link>
          <h1 class="text-2xl font-bold">{{ project.title }}</h1>
        </div>
        <div class="flex flex-wrap gap-2">
          <button
            @click="showEditModal = true"
            class="btn bg-yellow-500 hover:bg-yellow-600"
          >
            Editar Proyecto
          </button>
          <button
            @click="showCreateTaskModal = true"
            class="btn bg-green-500 hover:bg-green-600"
          >
            Nueva Tarea
          </button>
        </div>
      </div>

      <!-- Información del proyecto y estadísticas -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div class="md:col-span-2">
          <div class="card">
            <h2 class="text-xl font-semibold mb-4">Detalles del Proyecto</h2>
            <div class="mb-4">
              <p class="mb-2"><strong>Descripción:</strong></p>
              <p class="bg-gray-50 p-3 rounded">
                {{ project.description || "Sin descripción" }}
              </p>
            </div>
            <div class="flex flex-wrap gap-x-6 gap-y-2 text-sm">
              <p>
                <strong>Estado:</strong>
                <span
                  class="ml-2 px-2 py-1 text-xs rounded"
                  :class="{
                    'bg-green-100 text-green-800': project.status === 'ACTIVE',
                    'bg-yellow-100 text-yellow-800':
                      project.status === 'ON_HOLD',
                    'bg-blue-100 text-blue-800': project.status === 'COMPLETED',
                  }"
                >
                  {{ formatStatus(project.status) }}
                </span>
              </p>
              <p>
                <strong>Creado:</strong> {{ formatDateTime(project.createdAt) }}
              </p>
              <p>
                <strong>Última actualización:</strong>
                {{ formatDateTime(project.updatedAt) }}
              </p>
            </div>
          </div>
        </div>
        <div>
          <div class="card">
            <h2 class="text-xl font-semibold mb-4">Resumen de Tareas</h2>
            <div class="mb-4">
              <p class="text-2xl font-bold text-center">
                {{ completedTasks }} / {{ totalTasks }}
              </p>
              <p class="text-center text-gray-600">Tareas completadas</p>

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

            <div class="grid grid-cols-2 gap-2 text-center">
              <div class="bg-yellow-50 p-3 rounded">
                <p class="font-bold">{{ pendingTasks }}</p>
                <p class="text-xs text-gray-600">Pendientes</p>
              </div>
              <div class="bg-blue-50 p-3 rounded">
                <p class="font-bold">{{ inProgressTasks }}</p>
                <p class="text-xs text-gray-600">En progreso</p>
              </div>
              <div class="bg-green-50 p-3 rounded">
                <p class="font-bold">{{ completedTasks }}</p>
                <p class="text-xs text-gray-600">Completadas</p>
              </div>
              <div class="bg-red-50 p-3 rounded">
                <p class="font-bold">{{ highPriorityTasks }}</p>
                <p class="text-xs text-gray-600">Alta prioridad</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Lista de tareas -->
      <div class="card">
        <div
          class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-4 gap-2"
        >
          <h2 class="text-xl font-semibold">Tareas</h2>

          <div class="flex gap-2">
            <select
              v-model="taskFilters.status"
              class="input text-sm"
              @change="applyTaskFilters"
            >
              <option value="">Todos los estados</option>
              <option value="PENDING">Pendientes</option>
              <option value="IN_PROGRESS">En progreso</option>
              <option value="COMPLETED">Completadas</option>
            </select>

            <select
              v-model="taskFilters.priority"
              class="input text-sm"
              @change="applyTaskFilters"
            >
              <option value="">Todas las prioridades</option>
              <option value="LOW">Baja</option>
              <option value="MEDIUM">Media</option>
              <option value="HIGH">Alta</option>
            </select>
          </div>
        </div>

        <div
          v-if="!project.tasks || project.tasks.length === 0"
          class="text-center py-4"
        >
          <p class="mb-4">No hay tareas para este proyecto</p>
          <button @click="showCreateTaskModal = true" class="btn">
            Crear la primera tarea
          </button>
        </div>

        <div v-else-if="filteredTasks.length === 0" class="text-center py-4">
          <p class="mb-4">No hay tareas que coincidan con los filtros</p>
          <button @click="clearTaskFilters" class="btn">Limpiar filtros</button>
        </div>

        <div v-else class="overflow-x-auto">
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
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="font-medium text-gray-900">{{ task.title }}</div>
                  <div
                    v-if="task.description"
                    class="text-sm text-gray-500 truncate max-w-xs"
                  >
                    {{ task.description }}
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span
                    class="px-2 py-1 text-xs rounded"
                    :class="{
                      'bg-yellow-100 text-yellow-800':
                        task.status === 'PENDING',
                      'bg-blue-100 text-blue-800':
                        task.status === 'IN_PROGRESS',
                      'bg-green-100 text-green-800':
                        task.status === 'COMPLETED',
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
                      'bg-yellow-100 text-yellow-800':
                        task.priority === 'MEDIUM',
                      'bg-red-100 text-red-800': task.priority === 'HIGH',
                    }"
                  >
                    {{ formatPriority(task.priority) }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  {{ task.dueDate ? formatDate(task.dueDate) : "Sin fecha" }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                  <div class="flex gap-2">
                    <button
                      @click="handleEditTask(task)"
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

    <!-- Modal para editar proyecto -->
    <div
      v-if="showEditModal && project"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
    >
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
            <button type="submit" class="btn" :disabled="projectsStore.loading">
              {{ projectsStore.loading ? "Guardando..." : "Guardar Cambios" }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal para crear tarea -->
    <div
      v-if="showCreateTaskModal"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
    >
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h2 class="text-xl font-bold mb-4">Crear Nueva Tarea</h2>

        <TaskForm
          :task="newTask"
          :projects="[project]"
          :loading="tasksStore.loading"
          id="new-project-task"
          @submit="handleCreateTask"
          @cancel="showCreateTaskModal = false"
        />
      </div>
    </div>

    <!-- Modal para editar tarea -->
    <div
      v-if="showEditTaskModal && editingTask"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
    >
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h2 class="text-xl font-bold mb-4">Editar Tarea</h2>

        <TaskForm
          :task="editingTask"
          :projects="[project]"
          :loading="tasksStore.loading"
          id="edit-project-task"
          @submit="handleUpdateTask"
          @cancel="showEditTaskModal = false"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from "vue";
import { useRoute } from 'vue-router';
import { useProjectsStore } from "../../stores/projects";
import { useTasksStore } from "../../stores/tasks";
import { useNotification } from "../../composables/useNotification";
import TaskForm from '../../components/TaskForm.vue';


const route = useRoute();
const projectsStore = useProjectsStore();
const tasksStore = useTasksStore();
const { notify } = useNotification();

// Estado para modales
const showEditModal = ref(false);
const showCreateTaskModal = ref(false);
const showEditTaskModal = ref(false);
const editingProject = ref({});
const editingTask = ref(null);
const newTask = ref({
  title: "",
  description: "",
  status: "PENDING",
  priority: "MEDIUM",
  dueDate: "",
  projectId: "",
});

// Estado para filtros de tareas
const taskFilters = ref({
  status: "",
  priority: "",
});

// Obtener ID del proyecto y datos
const projectId = computed(() => route.params.id);
const project = computed(() => projectsStore.currentProject);

// Cargar proyecto al montar el componente o cuando cambie el ID
onMounted(async () => {
  await loadProject();
});

watch(projectId, async () => {
  await loadProject();
});

// Cargar el proyecto
const loadProject = async () => {
  try {
    await projectsStore.fetchProjectById(projectId.value);
    newTask.value.projectId = projectId.value;

    if (project.value) {
      editingProject.value = { ...project.value };
    }
  } catch (error) {
    notify("Error al cargar el proyecto", "error");
  }
};

// Calcular estadísticas
const totalTasks = computed(() => project.value?.tasks?.length || 0);

const pendingTasks = computed(
  () =>
    project.value?.tasks?.filter((task) => task.status === "PENDING").length ||
    0
);

const inProgressTasks = computed(
  () =>
    project.value?.tasks?.filter((task) => task.status === "IN_PROGRESS")
      .length || 0
);

const completedTasks = computed(
  () =>
    project.value?.tasks?.filter((task) => task.status === "COMPLETED")
      .length || 0
);

const highPriorityTasks = computed(
  () =>
    project.value?.tasks?.filter((task) => task.priority === "HIGH").length || 0
);

const completionPercentage = computed(() => {
  if (totalTasks.value === 0) return 0;
  return Math.round((completedTasks.value / totalTasks.value) * 100);
});

// Filtrar tareas
const filteredTasks = computed(() => {
  if (!project.value || !project.value.tasks) return [];

  let result = [...project.value.tasks];

  if (taskFilters.value.status) {
    result = result.filter((task) => task.status === taskFilters.value.status);
  }

  if (taskFilters.value.priority) {
    result = result.filter(
      (task) => task.priority === taskFilters.value.priority
    );
  }

  return result;
});

// Funciones para formatear datos
const formatStatus = (status) => {
  const statusMap = {
    ACTIVE: "Activo",
    ON_HOLD: "En pausa",
    COMPLETED: "Completado",
  };
  return statusMap[status] || status;
};

const formatTaskStatus = (status) => {
  const statusMap = {
    PENDING: "Pendiente",
    IN_PROGRESS: "En progreso",
    COMPLETED: "Completado",
  };
  return statusMap[status] || status;
};

const formatPriority = (priority) => {
  const priorityMap = {
    LOW: "Baja",
    MEDIUM: "Media",
    HIGH: "Alta",
  };
  return priorityMap[priority] || priority;
};

const formatDate = (dateString) => {
  if (!dateString) return "Sin fecha";
  const date = new Date(dateString);
  return date.toLocaleDateString();
};

const formatDateTime = (dateString) => {
  if (!dateString) return "Desconocido";
  const date = new Date(dateString);
  return `${date.toLocaleDateString()} ${date.toLocaleTimeString([], {
    hour: "2-digit",
    minute: "2-digit",
  })}`;
};

// Manipulación de tareas y proyecto
const applyTaskFilters = () => {
  // Los filtros se aplican automáticamente a través del computed
};

const clearTaskFilters = () => {
  taskFilters.value = {
    status: "",
    priority: "",
  };
};

const handleUpdateProject = async () => {
  try {
    await projectsStore.updateProject(projectId.value, editingProject.value);
    showEditModal.value = false;
    notify("Proyecto actualizado con éxito", "success");
  } catch (error) {
    notify("Error al actualizar el proyecto", "error");
  }
};

const handleCreateTask = async (taskData) => {
  try {
    await tasksStore.createTask(taskData || newTask.value);
    // Recargar el proyecto para actualizar la lista de tareas
    await projectsStore.fetchProjectById(projectId.value);
    showCreateTaskModal.value = false;

    // Reiniciar el formulario
    newTask.value = {
      title: "",
      description: "",
      status: "PENDING",
      priority: "MEDIUM",
      dueDate: "",
      projectId: projectId.value,
    };

    notify("Tarea creada con éxito", "success");
  } catch (error) {
    notify("Error al crear la tarea", "error");
  }
};

const handleEditTask = (task) => {
  // Convertir la fecha a formato YYYY-MM-DD para el input type="date"
  let taskCopy = { ...task };
  if (taskCopy.dueDate) {
    const date = new Date(taskCopy.dueDate);
    taskCopy.dueDate = date.toISOString().split("T")[0];
  }

  editingTask.value = taskCopy;
  showEditTaskModal.value = true;
};

const handleUpdateTask = async (taskData) => {
  try {
    const task = taskData || editingTask.value;
    await tasksStore.updateTask(task.id, task);
    // Recargar el proyecto para actualizar la lista de tareas
    await projectsStore.fetchProjectById(projectId.value);
    showEditTaskModal.value = false;
    notify("Tarea actualizada con éxito", "success");
  } catch (error) {
    notify("Error al actualizar la tarea", "error");
  }
};

const handleDeleteTask = async (id) => {
  if (confirm("¿Estás seguro de que deseas eliminar esta tarea?")) {
    try {
      await tasksStore.deleteTask(id);
      // Recargar el proyecto para actualizar la lista de tareas
      await projectsStore.fetchProjectById(projectId.value);
      notify("Tarea eliminada con éxito", "success");
    } catch (error) {
      notify("Error al eliminar la tarea", "error");
    }
  }
};

const markTaskAsCompleted = async (id) => {
  try {
    const task = project.value.tasks.find((t) => t.id === id);
    if (task) {
      await tasksStore.updateTask(id, { ...task, status: "COMPLETED" });
      // Recargar el proyecto para actualizar la lista de tareas
      await projectsStore.fetchProjectById(projectId.value);
      notify("Tarea marcada como completada", "success");
    }
  } catch (error) {
    notify("Error al actualizar la tarea", "error");
  }
};
</script>
