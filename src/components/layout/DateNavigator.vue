<template lang="pug">
  .date-navigator
    button(@click="prevDay") <
    span {{ formattedDate }}
    button(@click="nextDay") >
    button(@click="today") 今日
    //- 日付ピッカーのプレースホルダー
    button カレンダー
</template>

<script setup>
import { computed } from 'vue'
import { useCalendarStore } from '@/stores/calendar'
import { format, addDays } from 'date-fns'

const calendarStore = useCalendarStore()

const formattedDate = computed(() => {
  return format(calendarStore.currentDate, 'yyyy年MM月dd日(EEE)')
})

const prevDay = () => {
  calendarStore.changeDate(addDays(calendarStore.currentDate, -1))
}

const nextDay = () => {
  calendarStore.changeDate(addDays(calendarStore.currentDate, 1))
}

const today = () => {
  calendarStore.changeDate(new Date())
}
</script>

<style lang="sass" scoped>
.date-navigator
  display: flex
  align-items: center
  gap: 10px
  margin-bottom: 20px

  button
    padding: 8px 12px
    border: 1px solid #ccc
    border-radius: 4px
    background-color: #f0f0f0
    cursor: pointer

    &:hover
      background-color: #e0e0e0

  span
    font-size: 1.2em
    font-weight: bold
</style>