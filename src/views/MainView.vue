<template>
  <div>
    <h1>Main View</h1>
    <DateNavigator />
    <div class="calendar-grid">
      <PlanColumn />
      <!-- <ActualColumn /> -->
    </div>
  </div>
</template>

<script setup>
import DateNavigator from '../components/DateNavigator.vue'
import PlanColumn from '../components/PlanColumn.vue'
// import ActualColumn from '../components/ActualColumn.vue'
</script>

<style scoped>
.calendar-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
}
</style>
