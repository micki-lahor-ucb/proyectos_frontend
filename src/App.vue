<template>
  <div class="min-h-screen bg-gray-100 text-gray-800">
    <header v-if="isAuthenticated" class="bg-white shadow">
      <nav class="container mx-auto px-4 py-4 flex flex-col md:flex-row justify-between items-center">
        <div class="flex flex-col md:flex-row items-center mb-4 md:mb-0">
          <h1 class="text-xl font-bold text-blue-600 mb-2 md:mb-0">ProjectManager</h1>
          <div class="md:ml-6 space-y-2 md:space-y-0 md:space-x-4 text-center md:text-left">
            <router-link class="block md:inline-block text-gray-600 hover:text-blue-600" to="/">Inicio</router-link>
            <router-link class="block md:inline-block text-gray-600 hover:text-blue-600" to="/projects">Proyectos</router-link>
            <router-link class="block md:inline-block text-gray-600 hover:text-blue-600" to="/tasks">Tareas</router-link>
          </div>
        </div>
        <div class="flex items-center">
          <span class="mr-4 text-gray-600">{{ user?.name }}</span>
          <button @click="logout" class="btn">Cerrar sesión</button>
        </div>
      </nav>
    </header>

    <main class="container mx-auto px-4 py-8">
      <router-view />
    </main>

    <footer class="bg-gray-800 text-white py-6">
      <div class="container mx-auto px-4 text-center">
        <p>© 2025 ProjectManager - Sistema de Gestión de Proyectos</p>
      </div>
    </footer>
  </div>
</template>

<script setup>
import { computed, onMounted, watch } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useAuth } from './composables/useAuth';

const router = useRouter();
const route = useRoute();
const { isAuthenticated, user, logout, requireAuth } = useAuth();

// Verificar autenticación al cambiar de ruta
watch(
  () => route.path,
  (newPath) => {
    if (route.meta.requiresAuth && !isAuthenticated.value) {
      router.push('/login');
    }
    
    if (route.meta.requiresGuest && isAuthenticated.value) {
      router.push('/projects');
    }
  }
);

// Verificar autenticación al montar el componente
onMounted(() => {
  if (route.meta.requiresAuth && !isAuthenticated.value) {
    router.push('/login');
  }
  
  if (route.meta.requiresGuest && isAuthenticated.value) {
    router.push('/projects');
  }
});

</script>