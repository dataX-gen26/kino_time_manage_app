import { defineStore } from 'pinia'
import apiClient from '../api/client'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
  }),
  getters: {
    isLoggedIn: (state) => !!state.user,
  },
  actions: {
    async redirectToGoogle() {
      const generateRandomString = () => {
        const array = new Uint32Array(28)
        window.crypto.getRandomValues(array)
        return Array.from(array, (dec) => ('0' + dec.toString(16)).substr(-2)).join('')
      }

      const sha256 = async (plain) => {
        const encoder = new TextEncoder()
        const data = encoder.encode(plain)
        return window.crypto.subtle.digest('SHA-256', data)
      }

      const base64urlencode = (a) => {
        return btoa(String.fromCharCode.apply(null, new Uint8Array(a)))
          .replace(/\+/g, '-')
          .replace(/\//g, '_')
          .replace(/=+$/, '')
      }

      const verifier = generateRandomString()
      const challenge = base64urlencode(await sha256(verifier))

      sessionStorage.setItem('code_verifier', verifier)

      const params = new URLSearchParams({
        client_id: import.meta.env.VITE_GOOGLE_CLIENT_ID,
        redirect_uri: `${window.location.origin}/auth/callback`,
        response_type: 'code',
        scope: 'openid profile email https://www.googleapis.com/auth/calendar.readonly',
        code_challenge: challenge,
        code_challenge_method: 'S256',
      })

      window.location.href = `https://accounts.google.com/o/oauth2/v2/auth?${params}`
    },
    async handleAuthCallback(code) {
      const codeVerifier = sessionStorage.getItem('code_verifier')
      if (!codeVerifier) {
        throw new Error('Code verifier not found.')
      }

      try {
        const response = await apiClient.post('/auth/google/callback', {
          code,
          code_verifier: codeVerifier,
        })
        this.user = response.data
        sessionStorage.removeItem('code_verifier')
      } catch (error) {
        console.error('Failed to exchange authorization code for token:', error)
        this.user = null
        sessionStorage.removeItem('code_verifier')
        throw error
      }
    },
    async logout() {
      try {
        await apiClient.delete('/auth/logout')
        this.user = null
      } catch (error) {
        console.error('Logout failed:', error)
      }
    },
  },
})