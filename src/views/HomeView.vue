<template lang="pug">
.home-view
  h1 Time Management App
  button(@click="login") Googleでログイン
</template>

<script setup>
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()

const login = () => {
  authStore.redirectToGoogle()
}
</script>

<style lang="scss" scoped>
.home-view {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
}
</style>