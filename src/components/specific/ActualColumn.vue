<template lang="pug">
  .actual-column
    .actual-block(v-for="actual in actuals" :key="actual.id" :style="getActualStyle(actual)")
      | {{ actual.title }}
</template>

<script setup>
import { computed } from 'vue'
import { useCalendarStore } from '@/stores/calendar'
import { parseISO, differenceInMinutes, setHours, setMinutes } from 'date-fns'

const calendarStore = useCalendarStore()
const actuals = computed(() => calendarStore.actuals)

const getActualStyle = (actual) => {
  const start = parseISO(actual.start_time)
  const end = parseISO(actual.end_time)

  // 今日の0時0分を基準にする
  const startOfDay = setMinutes(setHours(calendarStore.currentDate, 0), 0)

  const top = differenceInMinutes(start, startOfDay) / 15 * 33.33 // 15分あたり33.33px
  const height = differenceInMinutes(end, start) / 15 * 33.33

  return {
    top: `${top}px`,
    height: `${height}px`,
    backgroundColor: '#d4edda',
    position: 'absolute',
    width: 'calc(100% - 20px)',
    left: '10px',
    borderRadius: '4px',
    padding: '5px',
    overflow: 'hidden',
    fontSize: '0.8em',
    border: '1px solid #28a745'
  }
}
</script>

<style lang="sass" scoped>
.actual-column
  position: relative
  height: 100%
  border: 1px solid #eee
  padding: 10px
  overflow-y: auto

.actual-block
  background-color: #d4edda
  border: 1px solid #28a745
  border-radius: 4px
  padding: 5px
  overflow: hidden
  font-size: 0.8em
  position: absolute
  width: calc(100% - 20px)
  left: 10px
</style>