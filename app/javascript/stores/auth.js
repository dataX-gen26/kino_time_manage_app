import { defineStore } from 'pinia';
import axios from 'axios';

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    isLoading: false,
  }),
  getters: {
    isLoggedIn: (state) => !!state.user,
  },
  actions: {
    async checkAuth() {
      this.isLoading = true;
      try {
        const response = await axios.get('/api/v1/sessions/check');
        this.user = response.data;
      } catch (error) {
        this.user = null;
        console.error('認証状態の確認に失敗しました:', error);
      } finally {
        this.isLoading = false;
      }
    },
    loginWithGoogle(persist) {
      window.location.href = `/api/v1/auth/google_oauth2?persist=${persist}`;
    },
    async logout() {
      try {
        await axios.delete('/api/v1/auth/logout');
        this.user = null;
      } catch (error) {
        console.error('ログアウトに失敗しました:', error);
      }
    },
  },
});
