import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import MainView from '../views/MainView.vue'
import { useAuthStore } from '../stores/auth'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView,
      meta: { requiresAuth: false }
    },
    {
      path: '/main',
      name: 'main',
      component: MainView,
      meta: { requiresAuth: true }
    },
  ]
})

router.beforeEach(async (to, from, next) => {
  const auth = useAuthStore()
  await auth.fetchUser()

  if (to.meta.requiresAuth && !auth.user) {
    next({ name: 'home' })
  } else if (to.name === 'home' && auth.user) {
    next({ name: 'main' })
  } else {
    next()
  }
})

export default router
