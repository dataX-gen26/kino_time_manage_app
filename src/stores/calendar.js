import { defineStore } from 'pinia'
import { format } from 'date-fns'

export const useCalendarStore = defineStore('calendar', {
  state: () => ({
    currentDate: format(new Date(), 'yyyy-MM-dd'),
    events: [],
  }),
  actions: {
    setCurrentDate(date) {
      this.currentDate = format(date, 'yyyy-MM-dd')
      this.fetchEvents()
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
  },
})
