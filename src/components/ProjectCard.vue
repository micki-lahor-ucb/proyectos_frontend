<template>
  <div class="card hover:shadow-lg transition-shadow">
    <div class="flex justify-between items-start">
      <h2 class="text-xl font-semibold mb-2">{{ project.title }}</h2>
      <span 
        class="px-2 py-1 text-xs rounded" 
        :class="statusClass"
      >
        {{ formatStatus(project.status) }}
      </span>
    </div>
    
    <p class="text-gray-600 mb-4">{{ project.description || 'Sin descripción' }}</p>
    
    <div class="flex justify-between items-center text-sm text-gray-500 mb-4">
      <div>
        <p>Tareas: {{ project.tasks ? project.tasks.length : 0 }}</p>
      </div>
      <div class="text-right">
        <p>Creado: {{ formatDate(project.createdAt) }}</p>
        <p>Actualizado: {{ formatDate(project.updatedAt) }}</p>
      </div>
    </div>
    
    <div class="flex flex-wrap justify-between gap-2">
      <router-link :to="`/projects/${project.id}`" class="btn">Ver detalles</router-link>
      <button @click="$emit('edit', project)" class="btn bg-yellow-500 hover:bg-yellow-600">Editar</button>
      <button @click="$emit('delete', project.id)" class="btn-danger">Eliminar</button>
    </div>

    <!-- Muestra una mini barra de progreso de las tareas -->
    <div v-if="project.tasks && project.tasks.length > 0" class="mt-4">
      <div class="flex justify-between text-xs mb-1">
        <span>Progreso</span>
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
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps({
  project: {
    type: Object,
    required: true,
  },
});

defineEmits(['edit', 'delete']);

const formatStatus = (status) => {
  const statusMap = {
    'ACTIVE': 'Activo',
    'ON_HOLD': 'En pausa',
    'COMPLETED': 'Completado',
  };
  return statusMap[status] || status;
};

const formatDate = (dateString) => {
  if (!dateString) return 'Desconocido';
  const date = new Date(dateString);
  return date.toLocaleDateString();
};

const statusClass = computed(() => {
  return {
    'bg-green-100 text-green-800': props.project.status === 'ACTIVE',
    'bg-yellow-100 text-yellow-800': props.project.status === 'ON_HOLD',
    'bg-blue-100 text-blue-800': props.project.status === 'COMPLETED',
  };
});

const completionPercentage = computed(() => {
  if (!props.project.tasks || props.project.tasks.length === 0) {
    return 0;
  }
  
  const completedTasks = props.project.tasks.filter(task => task.status === 'COMPLETED').length;
  return Math.round((completedTasks / props.project.tasks.length) * 100);
});
</script>