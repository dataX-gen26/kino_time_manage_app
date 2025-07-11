import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import LoginSuccess from '../views/LoginSuccess.vue'
import LoginFailure from '../views/LoginFailure.vue'
import MainView from '../views/MainView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView
    },
    {
      path: '/auth/callback',
      name: 'AuthCallback',
      component: () => import('../views/AuthCallback.vue')
    },
    {
      path: '/login/success',
      name: 'LoginSuccess',
      component: LoginSuccess
    },
    {
      path: '/login/failure',
      name: 'LoginFailure',
      component: LoginFailure
    },
    {
      path: '/main',
      name: 'Main',
      component: MainView
    }
  ]
})

export default router