<template>
  <div class="plan-column">
    <h2>Plan</h2>
    <div class="events">
      <div v-for="event in calendar.events" :key="event.id" class="event-item">
        <p>{{ event.summary }}</p>
        <p>{{ formatTime(event.start) }} - {{ formatTime(event.end) }}</p>
      </div>
      <p v-if="calendar.events.length === 0">No events for this day.</p>
    </div>
  </div>
</template>

<script setup>
import { useCalendarStore } from '../stores/calendar'
import { format, parseISO } from 'date-fns'
import { onMounted } from 'vue'

const calendar = useCalendarStore()

const formatTime = (dateTime) => {
  return format(parseISO(dateTime), 'HH:mm')
}

onMounted(() => {
  calendar.fetchEvents()
})
</script>

<style scoped>
.plan-column {
  border: 1px solid #ccc;
  padding: 1rem;
}
.event-item {
  background-color: #e0f7fa;
  margin-bottom: 0.5rem;
  padding: 0.5rem;
  border-radius: 4px;
}
</style>
