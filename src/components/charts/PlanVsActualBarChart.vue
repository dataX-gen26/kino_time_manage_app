<template>
  <Bar :data="chartData" :options="chartOptions" />
</template>

<script setup>
import { Chart as ChartJS, Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale } from 'chart.js'
import { Bar } from 'vue-chartjs'

ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale)

const props = defineProps({
  chartData: {
    type: Object,
    required: true,
  },
})

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  scales: {
    y: {
      title: {
        display: true,
        text: 'Hours',
      },
    },
  },
}
</script>
