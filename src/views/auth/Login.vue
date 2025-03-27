<template>
  <div class="flex justify-center">
    <div class="card w-full max-w-md">
      <h1 class="text-2xl font-bold mb-6 text-center">Iniciar sesión</h1>
      
      <div v-if="authStore.error" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
        {{ authStore.error }}
      </div>
      
      <form @submit.prevent="handleLogin">
        <div class="form-group">
          <label for="email" class="form-label">Email</label>
          <input
            id="email"
            v-model="email"
            type="email"
            class="input w-full"
            required
          />
        </div>
        
        <div class="form-group">
          <label for="password" class="form-label">Contraseña</label>
          <input
            id="password"
            v-model="password"
            type="password"
            class="input w-full"
            required
          />
        </div>
        
        <div class="mt-6">
          <button
            type="submit"
            class="btn w-full"
            :disabled="authStore.loading"
          >
            {{ authStore.loading ? 'Iniciando sesión...' : 'Iniciar sesión' }}
          </button>
        </div>
      </form>
      
      <div class="mt-4 text-center">
        <p>¿No tienes una cuenta? <router-link to="/register" class="text-blue-500 hover:text-blue-700">Regístrate</router-link></p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '../../stores/auth';

const authStore = useAuthStore();
const router = useRouter();

const email = ref('');
const password = ref('');

const handleLogin = async () => {
  const success = await authStore.login({
    email: email.value,
    password: password.value,
  });
  
  if (success) {
    router.push('/projects');
  }
};
</script>