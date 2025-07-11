<template lang="pug">
  .main-view
    h1 メイン画面
    DateNavigator
    CalendarGrid
</template>

<script setup>
import { onMounted } from 'vue'
import DateNavigator from '@/components/layout/DateNavigator.vue'
import CalendarGrid from '@/components/specific/CalendarGrid.vue'
import { useCalendarStore } from '@/stores/calendar'

const calendarStore = useCalendarStore()

onMounted(() => {
  calendarStore.fetchEvents(calendarStore.currentDate)
  calendarStore.fetchActuals(calendarStore.currentDate)
})
</script>

<style lang="sass" scoped>
.main-view
  padding: 20px
  h1
    font-size: 2em
    margin-bottom: 20px
</style>