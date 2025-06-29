<template>
  <div class="date-navigator">
    <button @click="prevDay">&lt;</button>
    <span>{{ formattedDate }}</span>
    <button @click="nextDay">&gt;</button>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useCalendarStore } from '../stores/calendar'
import { addDays, subDays, format, parseISO } from 'date-fns'

const calendar = useCalendarStore()

const formattedDate = computed(() => {
  return format(parseISO(calendar.currentDate), 'yyyy/MM/dd')
})

const prevDay = () => {
  const newDate = subDays(parseISO(calendar.currentDate), 1)
  calendar.setCurrentDate(newDate)
}

const nextDay = () => {
  const newDate = addDays(parseISO(calendar.currentDate), 1)
  calendar.setCurrentDate(newDate)
}
</script>

<style scoped>
.date-navigator {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}
</style>
