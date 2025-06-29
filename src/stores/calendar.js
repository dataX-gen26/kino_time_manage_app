import { defineStore } from 'pinia'
import { format } from 'date-fns'

export const useCalendarStore = defineStore('calendar', {
  state: () => ({
    currentDate: format(new Date(), 'yyyy-MM-dd'),
    events: [],
    actuals: [],
  }),
  actions: {
    setCurrentDate(date) {
      this.currentDate = format(date, 'yyyy-MM-dd')
      this.fetchEvents()
      this.fetchActuals()
    },
    async fetchEvents() {
      try {
        const res = await fetch(`/api/v1/calendar/events?date=${this.currentDate}`)
        if (res.ok) {
          this.events = await res.json()
        } else {
          this.events = []
          console.error('Failed to fetch events', res.statusText)
        }
      } catch (error) {
        this.events = []
        console.error('Error fetching events:', error)
      }
    },
    async fetchActuals() {
      try {
        const res = await fetch(`/api/v1/actuals?date=${this.currentDate}`)
        if (res.ok) {
          this.actuals = await res.json()
        } else {
          this.actuals = []
          console.error('Failed to fetch actuals', res.statusText)
        }
      } catch (error) {
        this.actuals = []
        console.error('Error fetching actuals:', error)
      }
    },
    async createActual(actual) {
      try {
        const res = await fetch('/api/v1/actuals', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ actual }),
        })
        if (res.ok) {
          this.fetchActuals()
        } else {
          console.error('Failed to create actual', res.statusText)
        }
      } catch (error) {
        console.error('Error creating actual:', error)
      }
    },
    async updateActual(id, actual) {
      try {
        const res = await fetch(`/api/v1/actuals/${id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ actual }),
        })
        if (res.ok) {
          this.fetchActuals()
        } else {
          console.error('Failed to update actual', res.statusText)
        }
      } catch (error) {
        console.error('Error updating actual:', error)
      }
    },
    async deleteActual(id) {
      try {
        const res = await fetch(`/api/v1/actuals/${id}`, {
          method: 'DELETE',
        })
        if (res.ok) {
          this.fetchActuals()
        } else {
          console.error('Failed to delete actual', res.statusText)
        }
      } catch (error) {
        console.error('Error deleting actual:', error)
      }
    },
  },
})
