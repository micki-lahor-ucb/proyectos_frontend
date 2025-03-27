<template>
  <div class="text-center">
    <h1 class="text-3xl font-bold mb-6">Bienvenido a ProjectManager</h1>
    
    <div v-if="!isLoggedIn" class="mb-6">
      <p class="mb-4">Para comenzar a gestionar tus proyectos, por favor inicia sesión o regístrate</p>
      <div class="space-x-4">
        <router-link to="/login" class="btn">Iniciar sesión</router-link>
        <router-link to="/register" class="btn bg-green-500 hover:bg-green-600">Registrarse</router-link>
      </div>
    </div>
    
    <div v-else class="mb-6">
      <p class="mb-4">Gestiona tus proyectos y tareas de manera eficiente</p>
      <div class="space-x-4">
        <router-link to="/projects" class="btn">Ver mis proyectos</router-link>
        <router-link to="/tasks" class="btn bg-green-500 hover:bg-green-600">Ver mis tareas</router-link>
      </div>
    </div>
    
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mt-12">
      <div class="card">
        <h2 class="text-xl font-semibold mb-3">Organiza tus proyectos</h2>
        <p>Crea y gestiona proyectos con facilidad, estableciendo fechas límite y prioridades.</p>
      </div>
      <div class="card">
        <h2 class="text-xl font-semibold mb-3">Controla tus tareas</h2>
        <p>Divide tus proyectos en tareas manejables y realiza un seguimiento de su progreso.</p>
      </div>
      <div class="card">
        <h2 class="text-xl font-semibold mb-3">Colabora eficientemente</h2>
        <p>Mantén todo organizado para colaborar de manera más efectiva con tu equipo.</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue';

const isLoggedIn = computed(() => {
  return !!localStorage.getItem('token');
});
</script>