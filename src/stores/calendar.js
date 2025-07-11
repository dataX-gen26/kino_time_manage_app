<script setup>
import { defineStore } from 'pinia'
import { ref } from 'vue'
import { format } from 'date-fns'
import * as calendarApi from '@/api/calendar'
import * as actualsApi from '@/api/actuals'

export const useCalendarStore = defineStore('calendar', () => {
  const currentDate = ref(new Date())
  const events = ref([])
  const actuals = ref([])
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

  const fetchActuals = async (date) => {
    isLoading.value = true
    try {
      const formattedDate = format(date, 'yyyy-MM-dd')
      const response = await actualsApi.getActuals(formattedDate)
      actuals.value = response.data
    } catch (error) {
      console.error('Failed to fetch actuals:', error)
      actuals.value = []
    } finally {
      isLoading.value = false
    }
  }

  const changeDate = (newDate) => {
    currentDate.value = newDate
    fetchEvents(newDate)
    fetchActuals(newDate)
  }

  return {
    currentDate,
    events,
    actuals,
    isLoading,
    fetchEvents,
    fetchActuals,
    changeDate
  }
})
</script>