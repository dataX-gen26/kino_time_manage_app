<template lang="pug">
.main-view
  h1 Main View
  p Welcome, {{ authStore.user?.name }}!
  button(@click="logout") Logout
</template>

<script setup>
import { useAuthStore } from '../stores/auth';

const authStore = useAuthStore();

const logout = () => {
  authStore.logout();
};
</script>

<style lang="scss" scoped>
.main-view {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
  text-align: center;
}
</style>
