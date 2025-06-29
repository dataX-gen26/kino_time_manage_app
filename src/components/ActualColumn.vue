<template>
  <div class="actual-column">
    <h2>Actual</h2>
    <div class="actuals">
      <div v-for="actual in calendar.actuals" :key="actual.id" class="actual-item">
        <p>{{ actual.content }}</p>
        <p>{{ formatTime(actual.start_time) }} - {{ formatTime(actual.end_time) }}</p>
        <p :style="{ backgroundColor: actual.category.color }">{{ actual.category.name }}</p>
      </div>
      <p v-if="calendar.actuals.length === 0">No actuals for this day.</p>
    </div>
    <button @click="openActualFormModal">Add Actual</button>
    <ActualFormModal ref="actualFormModal" />
  </div>
</template>

<script setup>
import { useCalendarStore } from '../stores/calendar'
import { format, parseISO } from 'date-fns'
import { onMounted, ref } from 'vue'
import ActualFormModal from './ActualFormModal.vue'

const calendar = useCalendarStore()
const actualFormModal = ref(null)

const formatTime = (dateTime) => {
  return format(parseISO(dateTime), 'HH:mm')
}

const openActualFormModal = () => {
  actualFormModal.value.openModal()
}

onMounted(() => {
  calendar.fetchActuals()
})
</script>

<style scoped>
.actual-column {
  border: 1px solid #ccc;
  padding: 1rem;
}
.actual-item {
  background-color: #e0f7fa;
  margin-bottom: 0.5rem;
  padding: 0.5rem;
  border-radius: 4px;
}
</style>
