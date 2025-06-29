<template lang="pug">
.home-view
  h1 Welcome to Time Management App
  .login-section
    label
      input(type="checkbox" v-model="persistLogin")
      | ログイン状態を維持する
    button(@click="login") Googleでログイン
</template>

<script setup>
import { ref } from 'vue';
import { useAuthStore } from '../stores/auth';

const authStore = useAuthStore();
const persistLogin = ref(false);

const login = () => {
  authStore.loginWithGoogle(persistLogin.value);
};
</script>

<style lang="scss" scoped>
.home-view {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
  text-align: center;

  .login-section {
    margin-top: 20px;

    label {
      margin-right: 10px;
    }

    button {
      padding: 10px 20px;
      background-color: #4285F4;
      color: white;
      border: none;
      border-radius: 5px;
      cursor: pointer;

      &:hover {
        background-color: #357ae8;
      }
    }
  }
}
</style>
