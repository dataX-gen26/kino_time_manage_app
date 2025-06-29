<template>
  <div class="weekly-review-view">
    <h1>Weekly Review</h1>

    <div class="week-selector">
      <BButton @click="prevWeek">&lt;</BButton>
      <span>{{ formattedWeek }}</span>
      <BButton @click="nextWeek">&gt;</BButton>
    </div>

    <div v-if="currentWeeklyGoal">
      <h2>{{ currentWeeklyGoal.title }}</h2>
      <p>{{ currentWeeklyGoal.description }}</p>
      <p>Status: {{ currentWeeklyGoal.status }}</p>

      <h3>Progresses</h3>
      <ul v-if="currentWeeklyGoal.weekly_goal_progresses && currentWeeklyGoal.weekly_goal_progresses.length > 0">
        <li v-for="progress in currentWeeklyGoal.weekly_goal_progresses" :key="progress.id">
          {{ format(parseISO(progress.progress_date), 'yyyy-MM-dd') }}: {{ progress.content }}
        </li>
      </ul>
      <p v-else>No progresses recorded for this week.</p>

      <BButton @click="generateWeeklyAiFeedback">AI Feedback</BButton>
      <BModal v-model="showAiFeedbackModal" title="Weekly AI Feedback" size="lg">
        <div v-html="renderedAiFeedback"></div>
        <template #modal-footer>
          <BButton variant="secondary" @click="showAiFeedbackModal = false">Close</BButton>
        </template>
      </BModal>
    </div>
    <div v-else>
      <p>No weekly goal found for this week.</p>
      <BButton @click="openWeeklyGoalSettingModal">Set Weekly Goal</BButton>
      <WeeklyGoalSettingModal ref="weeklyGoalSettingModal" />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useWeeklyGoalsStore } from '../stores/weeklyGoals'
import { format, parseISO, startOfWeek, endOfWeek, addWeeks, subWeeks } from 'date-fns'
import { marked } from 'marked'
import WeeklyGoalSettingModal from '../components/WeeklyGoalSettingModal.vue'

const weeklyGoalsStore = useWeeklyGoalsStore()
const selectedDate = ref(new Date())
const currentWeeklyGoal = ref(null)
const showAiFeedbackModal = ref(false)
const aiFeedbackContent = ref('')
const weeklyGoalSettingModal = ref(null)

const formattedWeek = computed(() => {
  const start = format(startOfWeek(selectedDate.value, { weekStartsOn: 1 }), 'yyyy/MM/dd')
  const end = format(endOfWeek(selectedDate.value, { weekStartsOn: 1 }), 'yyyy/MM/dd')
  return `${start} - ${end}`
})

const fetchWeeklyGoal = async () => {
  await weeklyGoalsStore.fetchWeeklyGoals()
  const start = startOfWeek(selectedDate.value, { weekStartsOn: 1 })
  const end = endOfWeek(selectedDate.value, { weekStartsOn: 1 })
  currentWeeklyGoal.value = weeklyGoalsStore.weeklyGoals.find(goal => {
    const goalStart = parseISO(goal.start_date)
    const goalEnd = parseISO(goal.end_date)
    return goalStart <= end && goalEnd >= start
  })
}

const prevWeek = () => {
  selectedDate.value = subWeeks(selectedDate.value, 1)
}

const nextWeek = () => {
  selectedDate.value = addWeeks(selectedDate.value, 1)
}

const generateWeeklyAiFeedback = async () => {
  if (!currentWeeklyGoal.value) return

  try {
    const res = await fetch('/api/v1/ai/weekly_review', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        weekly_goal_id: currentWeeklyGoal.value.id,
      }),
    })
    if (res.ok) {
      const data = await res.json()
      aiFeedbackContent.value = data.feedback
      showAiFeedbackModal.value = true
    } else {
      console.error('Failed to get weekly AI feedback', res.statusText)
      aiFeedbackContent.value = 'Failed to get weekly AI feedback.'
      showAiFeedbackModal.value = true
    }
  } catch (error) {
    console.error('Error getting weekly AI feedback:', error)
    aiFeedbackContent.value = 'Error getting weekly AI feedback.'
    showAiFeedbackModal.value = true
  }
}

const renderedAiFeedback = computed(() => {
  return marked(aiFeedbackContent.value)
})

const openWeeklyGoalSettingModal = () => {
  weeklyGoalSettingModal.value.openModal()
}

onMounted(() => {
  fetchWeeklyGoal()
})

watch(selectedDate, () => {
  fetchWeeklyGoal()
})
</script>

<style scoped>
.weekly-review-view {
  padding: 1rem;
}
.week-selector {
  display: flex;
  justify-content: center;
  gap: 1rem;
  margin-bottom: 1rem;
}
</style>
