import { createRouter, createWebHistory } from 'vue-router';
import HomeView from '../views/HomeView.vue';
import MainView from '../views/MainView.vue';
import { useAuthStore } from '../stores/auth';

const routes = [
  {
    path: '/',
    name: 'home',
    component: HomeView,
    meta: { requiresAuth: false },
  },
  {
    path: '/main',
    name: 'main',
    component: MainView,
    meta: { requiresAuth: true },
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore();

  if (!authStore.user && !authStore.isLoading) {
    await authStore.checkAuth();
  }

  if (to.meta.requiresAuth && !authStore.isLoggedIn) {
    next({ name: 'home' });
  } else if (to.name === 'home' && authStore.isLoggedIn) {
    next({ name: 'main' });
  } else {
    next();
  }
});

export default router;
