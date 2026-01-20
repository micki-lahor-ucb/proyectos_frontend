<template>
  <form @submit.prevent="emit('submit', localTask)">
    <div class="form-group">
      <label :for="`${id}-title`" class="form-label">Título</label>
      <input
        :id="`${id}-title`"
        v-model="localTask.title"
        type="text"
        class="input w-full"
        required
      />
    </div>
    
    <div class="form-group">
      <label :for="`${id}-description`" class="form-label">Descripción</label>
      <textarea
        :id="`${id}-description`"
        v-model="localTask.description"
        class="input w-full"
        rows="3"
      ></textarea>
    </div>
    
    <div class="form-group">
      <label :for="`${id}-project`" class="form-label">Proyecto</label>
      <select
        :id="`${id}-project`"
        v-model="localTask.projectId"
        class="input w-full"
        required
      >
        <option value="">Seleccionar proyecto</option>
        <option v-for="project in projects" :key="project.id" :value="project.id">
          {{ project.title }}
        </option>
      </select>
    </div>
    
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <div class="form-group">
        <label :for="`${id}-status`" class="form-label">Estado</label>
        <select
          :id="`${id}-status`"
          v-model="localTask.status"
          class="input w-full"
        >
          <option value="PENDING">Pendiente</option>
          <option value="IN_PROGRESS">En progreso</option>
          <option value="COMPLETED">Completado</option>
        </select>
      </div>
      
      <div class="form-group">
        <label :for="`${id}-priority`" class="form-label">Prioridad</label>
        <select
          :id="`${id}-priority`"
          v-model="localTask.priority"
          class="input w-full"
        >
          <option value="LOW">Baja</option>
          <option value="MEDIUM">Media</option>
          <option value="HIGH">Alta</option>
        </select>
      </div>
    </div>
    
    <div class="form-group">
      <label :for="`${id}-due-date`" class="form-label">Fecha límite</label>
      <input
        :id="`${id}-due-date`"
        v-model="localTask.dueDate"
        type="date"
        class="input w-full"
      />
    </div>
    
    <div class="flex justify-end mt-6 space-x-2">
      <button 
        type="button" 
        @click="emit('cancel')" 
        class="px-4 py-2 bg-gray-200 text-gray-800 rounded hover:bg-gray-300"
      >
        Cancelar
      </button>
      <button 
        type="submit" 
        class="btn"
        :disabled="loading"
      >
        {{ loading ? (isNew ? 'Creando...' : 'Guardando...') : (isNew ? 'Crear Tarea' : 'Guardar Cambios') }}
      </button>
    </div>
  </form>
</template>

<script setup>
import { computed, ref, watch } from 'vue';

const props = defineProps({
  task: {
    type: Object,
    required: true,
  },
  projects: {
    type: Array,
    default: () => [],
  },
  loading: {
    type: Boolean,
    default: false,
  },
  id: {
    type: String,
    default: 'task',
  },
});

const emit = defineEmits(['submit', 'cancel']);

const isNew = computed(() => !props.task.id);

// Crear una copia local del task para evitar mutar props
const localTask = ref({ ...props.task });

// Sincronizar cuando cambie el prop
watch(
  () => props.task,
  (newTask) => {
    localTask.value = { ...newTask };
  },
  { deep: true },
);
</script>