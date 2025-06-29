import { defineStore } from 'pinia'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
  }),
  actions: {
    async fetchUser() {
      const res = await fetch('/api/v1/users/me')
      if (res.ok) {
        this.user = await res.json()
      } else {
        this.user = null
      }
    },
    login() {
      window.location.href = '/auth/google_oauth2'
    },
    logout() {
      fetch('/logout', { method: 'DELETE' }).then(() => {
        this.user = null
        window.location.href = '/'
      })
    },
  },
})
