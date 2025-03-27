<template>
  <div v-if="show" class="fixed top-4 right-4 z-50 p-4 rounded shadow-lg transition-all duration-500" :class="typeClass">
    <div class="flex justify-between items-center">
      <p>{{ message }}</p>
      <button @click="close" class="ml-4 text-xl font-bold">&times;</button>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, onMounted } from 'vue';

const props = defineProps({
  type: {
    type: String,
    default: 'success',
    validator: (value) => ['success', 'error', 'info', 'warning'].includes(value),
  },
  message: {
    type: String,
    required: true,
  },
  duration: {
    type: Number,
    default: 3000,
  },
  autoClose: {
    type: Boolean,
    default: true,
  },
});

const emit = defineEmits(['close']);

const show = ref(false);

const typeClass = computed(() => {
  return {
    'bg-green-100 text-green-800': props.type === 'success',
    'bg-red-100 text-red-800': props.type === 'error',
    'bg-blue-100 text-blue-800': props.type === 'info',
    'bg-yellow-100 text-yellow-800': props.type === 'warning',
  };
});

const close = () => {
  show.value = false;
  emit('close');
};

onMounted(() => {
  show.value = true;
  
  if (props.autoClose) {
    setTimeout(() => {
      close();
    }, props.duration);
  }
});
</script>