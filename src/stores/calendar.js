<script setup>
import { defineStore } from 'pinia'
import { ref } from 'vue'
import { format } from 'date-fns'
import * as calendarApi from '@/api/calendar'

export const useCalendarStore = defineStore('calendar', () => {
  const currentDate = ref(new Date())
  const events = ref([])
  const isLoading = ref(false)

  const fetchEvents = async (date) => {
    isLoading.value = true
    try {
      const formattedDate = format(date, 'yyyy-MM-dd')
      const response = await calendarApi.getEvents(formattedDate)
      events.value = response.data
    } catch (error) {
      console.error('Failed to fetch calendar events:', error)
      events.value = []
    } finally {
      isLoading.value = false
    }
  }

  const changeDate = (newDate) => {
    currentDate.value = newDate
    fetchEvents(newDate)
  }

  return {
    currentDate,
    events,
    isLoading,
    fetchEvents,
    changeDate
  }
})
</script>