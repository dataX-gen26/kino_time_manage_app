<template>
  <div class="dashboard-view">
    <h1>Dashboard</h1>

    <div class="period-selector">
      <BButtonGroup>
        <BButton :variant="period === 'daily' ? 'primary' : 'outline-primary'" @click="setPeriod('daily')">Daily</BButton>
        <BButton :variant="period === 'weekly' ? 'primary' : 'outline-primary'" @click="setPeriod('weekly')">Weekly</BButton>
        <BButton :variant="period === 'monthly' ? 'primary' : 'outline-primary'" @click="setPeriod('monthly')">Monthly</BButton>
      </BButtonGroup>

      <BInputGroup class="date-navigator">
        <BButton @click="prevDate">&lt;</BButton>
        <BFormInput type="date" v-model="selectedDate" @change="fetchSummary"></BFormInput>
        <BButton @click="nextDate">&gt;</BButton>
      </BInputGroup>
    </div>

    <div v-if="summaryData">
      <h2>Category Distribution ({{ period }})</h2>
      <CategoryPieChart :chart-data="categoryPieChartData" />

      <div v-if="period !== 'daily'">
        <h2>Daily Activity Trend</h2>
        <ActivityBarChart :chart-data="activityBarChartData" />

        <h2>Productivity Trend</h2>
        <ProductivityLineChart :chart-data="productivityLineChartData" />

        <h2>Plan vs Actual</h2>
        <PlanVsActualBarChart :chart-data="planVsActualBarChartData" />
      </div>
    </div>
    <div v-else>
      <p>Loading dashboard data...</p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { format, parseISO, addDays, subDays, addWeeks, subWeeks, addMonths, subMonths } from 'date-fns'
import CategoryPieChart from '../components/charts/CategoryPieChart.vue'
import ActivityBarChart from '../components/charts/ActivityBarChart.vue'
import ProductivityLineChart from '../components/charts/ProductivityLineChart.vue'
import PlanVsActualBarChart from '../components/charts/PlanVsActualBarChart.vue'

const period = ref('daily')
const selectedDate = ref(format(new Date(), 'yyyy-MM-dd'))
const summaryData = ref(null)

const fetchSummary = async () => {
  try {
    const res = await fetch(`/api/v1/dashboard/summary?period=${period.value}&date=${selectedDate.value}`)
    if (res.ok) {
      summaryData.value = await res.json()
    } else {
      console.error('Failed to fetch summary', res.statusText)
      summaryData.value = null
    }
  } catch (error) {
    console.error('Error fetching summary:', error)
    summaryData.value = null
  }
}

const setPeriod = (newPeriod) => {
  period.value = newPeriod
  fetchSummary()
}

const prevDate = () => {
  let newDate
  switch (period.value) {
    case 'daily':
      newDate = subDays(parseISO(selectedDate.value), 1)
      break
    case 'weekly':
      newDate = subWeeks(parseISO(selectedDate.value), 1)
      break
    case 'monthly':
      newDate = subMonths(parseISO(selectedDate.value), 1)
      break
  }
  selectedDate.value = format(newDate, 'yyyy-MM-dd')
  fetchSummary()
}

const nextDate = () => {
  let newDate
  switch (period.value) {
    case 'daily':
      newDate = addDays(parseISO(selectedDate.value), 1)
      break
    case 'weekly':
      newDate = addWeeks(parseISO(selectedDate.value), 1)
      break
    case 'monthly':
      newDate = addMonths(parseISO(selectedDate.value), 1)
      break
  }
  selectedDate.value = format(newDate, 'yyyy-MM-dd')
  fetchSummary()
}

const categoryPieChartData = computed(() => {
  if (!summaryData.value) return { labels: [], datasets: [] }
  const labels = summaryData.value.category_distribution.map(d => d.category_name)
  const data = summaryData.value.category_distribution.map(d => d.duration_seconds / 3600)
  const colors = summaryData.value.category_distribution.map(d => d.category_color)

  return {
    labels: labels,
    datasets: [
      {
        backgroundColor: colors,
        data: data,
      },
    ],
  }
})

const activityBarChartData = computed(() => {
  if (!summaryData.value || !summaryData.value.daily_activity) return { labels: [], datasets: [] }

  const labels = summaryData.value.daily_activity.map(d => format(parseISO(d.date), 'MM/dd'))
  const datasets = []
  const categoryNames = [...new Set(summaryData.value.daily_activity.flatMap(d => d.category_distribution.map(cat => cat.category_name)))]

  categoryNames.forEach(catName => {
    const data = summaryData.value.daily_activity.map(d => {
      const categoryData = d.category_distribution.find(cat => cat.category_name === catName)
      return categoryData ? categoryData.duration_seconds / 3600 : 0
    })
    const color = summaryData.value.daily_activity.flatMap(d => d.category_distribution).find(cat => cat.category_name === catName)?.category_color || '#ccc'
    datasets.push({
      label: catName,
      backgroundColor: color,
      data: data,
    })
  })

  return {
    labels: labels,
    datasets: datasets,
  }
})

const productivityLineChartData = computed(() => {
  if (!summaryData.value || !summaryData.value.productivity_trend) return { labels: [], datasets: [] }

  const labels = summaryData.value.productivity_trend.map(d => format(parseISO(d.date), 'MM/dd'))
  const productiveData = summaryData.value.productivity_trend.map(d => d.productive_time_seconds / 3600)
  const unproductiveData = summaryData.value.productivity_trend.map(d => d.unproductive_time_seconds / 3600)
  const problemData = summaryData.value.productivity_trend.map(d => d.problem_time_seconds / 3600)

  return {
    labels: labels,
    datasets: [
      {
        label: 'Productive Time',
        borderColor: '#42b983',
        data: productiveData,
        fill: false,
      },
      {
        label: 'Unproductive Time',
        borderColor: '#ff6384',
        data: unproductiveData,
        fill: false,
      },
      {
        label: 'Problem Time',
        borderColor: '#ffcd56',
        data: problemData,
        fill: false,
      },
    ],
  }
})

const planVsActualBarChartData = computed(() => {
  if (!summaryData.value || !summaryData.value.plan_vs_actual) return { labels: [], datasets: [] }

  const labels = summaryData.value.plan_vs_actual.map(d => format(parseISO(d.date), 'MM/dd'))
  const plannedData = summaryData.value.plan_vs_actual.map(d => d.planned_time_seconds / 3600)
  const executedData = summaryData.value.plan_vs_actual.map(d => d.executed_time_seconds / 3600)

  return {
    labels: labels,
    datasets: [
      {
        label: 'Planned Time',
        backgroundColor: '#36a2eb',
        data: plannedData,
      },
      {
        label: 'Executed Time',
        backgroundColor: '#ff6384',
        data: executedData,
      },
    ],
  }
})

onMounted(() => {
  fetchSummary()
})

watch(selectedDate, () => {
  fetchSummary()
})
</script>

<style scoped>
.dashboard-view {
  padding: 1rem;
}
.period-selector {
  display: flex;
  justify-content: center;
  gap: 1rem;
  margin-bottom: 1rem;
}
.date-navigator {
  width: 200px;
}
</style>
