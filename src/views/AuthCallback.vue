<template lang="pug">
.auth-callback
  p Authenticating...
</template>

<script setup>
import { onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

onMounted(async () => {
  const code = route.query.code
  if (code) {
    try {
      await authStore.handleAuthCallback(code)
      router.push('/login/success')
    } catch (error) {
      console.error('Authentication failed:', error)
      router.push('/login/failure')
    }
  } else {
    console.error('No authorization code found.')
    router.push('/login/failure')
  }
})
</script>