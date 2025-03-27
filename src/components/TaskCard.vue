<template>
  <div class="card hover:shadow-lg transition-shadow border-l-4" :class="statusBorderClass">
    <div class="flex justify-between items-start">
      <h3 class="font-semibold text-lg mb-2">{{ task.title }}</h3>
      <div class="flex gap-1">
        <span 
          class="px-2 py-1 text-xs rounded" 
          :class="statusClass"
        >
          {{ formatStatus(task.status) }}
        </span>
        <span 
          class="px-2 py-1 text-xs rounded" 
          :class="priorityClass"
        >
          {{ formatPriority(task.priority) }}
        </span>
      </div>
    </div>
    
    <p v-if="task.description" class="text-gray-600 mb-3 text-sm">
      {{ truncateDescription(task.description) }}
    </p>
    
    <div class="flex justify-between items-center text-sm text-gray-500 mb-4">
      <div>
        <p v-if="showProject && task.project">
          <span class="text-xs">Proyecto: </span>
          <router-link :to="`/projects/${task.project.id}`" class="text-blue-500 hover:text-blue-700">
            {{ task.project.title }}
          </router-link>
        </p>
      </div>
      <div class="text-right">
        <p v-if="task.dueDate" :class="{ 'text-red-500': isOverdue }">
          <span class="text-xs">Fecha límite: </span>
          {{ formatDate(task.dueDate) }}
        </p>
      </div>
    </div>
    
    <div class="flex flex-wrap justify-between gap-2">
      <button @click="$emit('edit', task)" class="btn bg-blue-500 hover:bg-blue-600 text-sm py-1">Editar</button>
      <button 
        v-if="task.status !== 'COMPLETED'" 
        @click="$emit('complete', task.id)" 
        class="btn bg-green-500 hover:bg-green-600 text-sm py-1"
      >
        Completar
      </button>
      <button @click="$emit('delete', task.id)" class="btn-danger text-sm py-1">Eliminar</button>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps({
  task: {
    type: Object,
    required: true,
  },
  showProject: {
    type: Boolean,
    default: true,
  },
});

defineEmits(['edit', 'delete', 'complete']);

const formatStatus = (status) => {
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
  if (!dateString) return '';
  const date = new Date(dateString);
  return date.toLocaleDateString();
};

const truncateDescription = (description, maxLength = 100) => {
  if (!description) return '';
  if (description.length <= maxLength) return description;
  return description.substring(0, maxLength) + '...';
};

const isOverdue = computed(() => {
  if (!props.task.dueDate) return false;
  const dueDate = new Date(props.task.dueDate);
  const today = new Date();
  return dueDate < today && props.task.status !== 'COMPLETED';
});

const statusClass = computed(() => {
  return {
    'bg-yellow-100 text-yellow-800': props.task.status === 'PENDING',
    'bg-blue-100 text-blue-800': props.task.status === 'IN_PROGRESS',
    'bg-green-100 text-green-800': props.task.status === 'COMPLETED',
  };
});

const priorityClass = computed(() => {
  return {
    'bg-green-100 text-green-800': props.task.priority === 'LOW',
    'bg-yellow-100 text-yellow-800': props.task.priority === 'MEDIUM',
    'bg-red-100 text-red-800': props.task.priority === 'HIGH',
  };
});

const statusBorderClass = computed(() => {
  return {
    'border-yellow-400': props.task.status === 'PENDING',
    'border-blue-400': props.task.status === 'IN_PROGRESS',
    'border-green-400': props.task.status === 'COMPLETED',
  };
});
</script>