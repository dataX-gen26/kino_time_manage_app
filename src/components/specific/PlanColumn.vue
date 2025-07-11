<template lang="pug">
  .plan-column
    .event-block(v-for="event in events" :key="event.id" :style="getEventStyle(event)")
      | {{ event.summary }}
</template>

<script setup>
import { computed } from 'vue'
import { useCalendarStore } from '@/stores/calendar'
import { parseISO, differenceInMinutes, setHours, setMinutes } from 'date-fns'

const calendarStore = useCalendarStore()
const events = computed(() => calendarStore.events)

const getEventStyle = (event) => {
  const start = parseISO(event.start.dateTime || event.start.date)
  const end = parseISO(event.end.dateTime || event.end.date)

  // 今日の0時0分を基準にする
  const startOfDay = setMinutes(setHours(calendarStore.currentDate, 0), 0)

  const top = differenceInMinutes(start, startOfDay) / 15 * 33.33 // 15分あたり33.33px
  const height = differenceInMinutes(end, start) / 15 * 33.33

  return {
    top: `${top}px`,
    height: `${height}px`,
    backgroundColor: '#a7d9ff',
    position: 'absolute',
    width: 'calc(100% - 20px)',
    left: '10px',
    borderRadius: '4px',
    padding: '5px',
    overflow: 'hidden',
    fontSize: '0.8em',
    border: '1px solid #6cb7ed'
  }
}
</script>

<style lang="sass" scoped>
.plan-column
  position: relative
  height: 100%
  border: 1px solid #eee
  padding: 10px
  overflow-y: auto

.event-block
  background-color: #a7d9ff
  border: 1px solid #6cb7ed
  border-radius: 4px
  padding: 5px
  overflow: hidden
  font-size: 0.8em
  position: absolute
  width: calc(100% - 20px)
  left: 10px
</style>