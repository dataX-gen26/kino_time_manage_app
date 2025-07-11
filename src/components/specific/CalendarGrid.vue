<template lang="pug">
  .calendar-grid
    .time-axis
      .time-label(v-for="hour in 24" :key="hour") {{ hour - 1 }}:00
    .plan-column-wrapper
      h3 予定 (Plan)
      PlanColumn
    .actual-column
      h3 実績 (Actual)
      //- ActualColumn コンポーネントをここに配置
</template>

<script setup>
import PlanColumn from '@/components/specific/PlanColumn.vue'
</script>

<style lang="sass" scoped>
.calendar-grid
  display: grid
  grid-template-columns: 60px 1fr 1fr // 時間軸、予定、実績
  gap: 10px
  border: 1px solid #eee
  height: 800px // 仮の高さ
  overflow-y: auto

.time-axis
  display: flex
  flex-direction: column
  .time-label
    height: 33.33px // 15分単位で4行、1時間で4行 * 15分 = 60分
    line-height: 33.33px
    text-align: right
    padding-right: 5px
    border-bottom: 1px dotted #eee
    &:last-child
      border-bottom: none

.plan-column-wrapper,
.actual-column
  border: 1px solid #eee
  padding: 10px
  h3
    text-align: center
    margin-bottom: 10px
</style>