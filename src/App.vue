<template>
  <div class="min-h-screen bg-gray-100">
    <header v-if="isLoggedIn" class="bg-white shadow">
      <nav class="container mx-auto px-4 py-4 flex justify-between items-center">
        <div class="flex items-center">
          <h1 class="text-xl font-bold text-blue-600">ProjectManager</h1>
          <div class="ml-6 space-x-4">
            <router-link class="text-gray-600 hover:text-blue-600" to="/">Inicio</router-link>
            <router-link class="text-gray-600 hover:text-blue-600" to="/projects">Proyectos</router-link>
            <router-link class="text-gray-600 hover:text-blue-600" to="/tasks">Tareas</router-link>
          </div>
        </div>
        <div>
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
import { computed } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();

const isLoggedIn = computed(() => {
  return !!localStorage.getItem('token');
});

const user = computed(() => {
  const userStr = localStorage.getItem('user');
  return userStr ? JSON.parse(userStr) : null;
});

const logout = () => {
  localStorage.removeItem('token');
  localStorage.removeItem('user');
  router.push('/login');
};
</script>