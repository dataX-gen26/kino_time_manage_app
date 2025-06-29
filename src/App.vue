<template>
  <div id="app">
    <header>
      <button v-if="!auth.user" @click="auth.login">Login with Google</button>
      <div v-if="auth.user">
        <img :src="auth.user.image_url" alt="user avatar" width="32" height="32">
        <span>{{ auth.user.name }}</span>
        <router-link to="/main">Main</router-link>
        <router-link to="/dashboard">Dashboard</router-link>
        <router-link to="/weekly-review">Weekly Review</router-link>
        <button @click="auth.logout">Logout</button>
      </div>
    </header>
    <router-view />
  </div>
</template>

<script setup>
import { useAuthStore } from './stores/auth'
import { onMounted } from 'vue'

const auth = useAuthStore()

onMounted(() => {
  auth.fetchUser()
})
</script>
