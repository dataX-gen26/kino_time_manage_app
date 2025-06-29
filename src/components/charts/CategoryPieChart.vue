<template>
  <Pie :data="chartData" :options="chartOptions" />
</template>

<script setup>
import { Chart as ChartJS, ArcElement, Tooltip, Legend } from 'chart.js'
import { Pie } from 'vue-chartjs'

ChartJS.register(ArcElement, Tooltip, Legend)

const props = defineProps({
  chartData: {
    type: Object,
    required: true,
  },
})

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
}
</script>
