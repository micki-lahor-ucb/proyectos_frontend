import { createRouter, createWebHistory } from 'vue-router';

// Importación de vistas
const Home = () => import('../views/Home.vue');
const Login = () => import('../views/auth/Login.vue');
const Register = () => import('../views/auth/Register.vue');
const ProjectList = () => import('../views/projects/ProjectList.vue');
const ProjectDetail = () => import('../views/projects/ProjectDetail.vue');
const TaskList = () => import('../views/tasks/TaskList.vue');

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home,
  },
  {
    path: '/login',
    name: 'Login',
    component: Login,
    meta: { requiresGuest: true }
  },
  {
    path: '/register',
    name: 'Register',
    component: Register,
    meta: { requiresGuest: true }
  },
  {
    path: '/projects',
    name: 'ProjectList',
    component: ProjectList,
    meta: { requiresAuth: true }
  },
  {
    path: '/projects/:id',
    name: 'ProjectDetail',
    component: ProjectDetail,
    meta: { requiresAuth: true }
  },
  {
    path: '/tasks',
    name: 'TaskList',
    component: TaskList,
    meta: { requiresAuth: true }
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

// Navegación guard para rutas protegidas
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token');
  
  if (to.meta.requiresAuth && !token) {
    next({ name: 'Login' });
  } else if (to.meta.requiresGuest && token) {
    next({ name: 'ProjectList' });
  } else {
    next();
  }
});

export default router;