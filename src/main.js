import './assets/index.css'

import { createApp } from 'vue'
import { createPinia } from 'pinia'

import App from './App.vue'
import router from './router'
import apiClient from './api/client'

const app = createApp(App)

app.use(createPinia())
app.use(router)

async function initializeApp() {
  try {
    const response = await apiClient.get('/csrf_token')
    apiClient.defaults.headers.common['X-CSRF-Token'] = response.data.csrf_token
  } catch (error) {
    console.error('CSRF token fetch failed:', error)
  }
  app.mount('#app')
}

initializeApp()