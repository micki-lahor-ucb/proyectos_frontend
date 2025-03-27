import { computed } from 'vue';
import { useAuthStore } from '../stores/auth';
import { useRouter } from 'vue-router';

export function useAuth() {
  const authStore = useAuthStore();
  const router = useRouter();

  const isAuthenticated = computed(() => authStore.isAuthenticated);
  const user = computed(() => authStore.getUser);

  const login = async (credentials) => {
    const success = await authStore.login(credentials);
    if (success) {
      router.push('/projects');
    }
    return success;
  };

  const register = async (userData) => {
    const success = await authStore.register(userData);
    if (success) {
      router.push('/login');
    }
    return success;
  };

  const logout = () => {
    authStore.logout();
    router.push('/login');
  };

  const requireAuth = () => {
    if (!isAuthenticated.value) {
      router.push('/login');
      return false;
    }
    return true;
  };

  return {
    isAuthenticated,
    user,
    login,
    register,
    logout,
    requireAuth,
  };
}