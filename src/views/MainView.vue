<template>
  <div>
    <h1>Main View</h1>
    <DateNavigator />
    <BButton @click="showDailyReview">今日の振り返り (AI)</BButton>
    <BButton @click="openWeeklyGoalSettingModal">週次目標設定</BButton>
    <div class="calendar-grid">
      <PlanColumn />
      <ActualColumn />
    </div>
    <BModal v-model="showReviewModal" title="今日の振り返り (AI)" size="lg">
      <div v-html="renderedFeedback"></div>
      <template #modal-footer>
        <BButton variant="secondary" @click="showReviewModal = false">Close</BButton>
      </template>
    </BModal>
    <WeeklyGoalSettingModal ref="weeklyGoalSettingModal" />
  </div>
</template>

<script setup>
import DateNavigator from '../components/DateNavigator.vue'
import PlanColumn from '../components/PlanColumn.vue'
import ActualColumn from '../components/ActualColumn.vue'
import WeeklyGoalSettingModal from '../components/WeeklyGoalSettingModal.vue'
import { ref, computed } from 'vue'
import { useCalendarStore } from '../stores/calendar'
import { marked } from 'marked'

const calendar = useCalendarStore()
const showReviewModal = ref(false)
const feedbackContent = ref('')
const weeklyGoalSettingModal = ref(null)

const renderedFeedback = computed(() => {
  return marked(feedbackContent.value)
})

const showDailyReview = async () => {
  try {
    const res = await fetch('/api/v1/ai/daily_review', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ date: calendar.currentDate }),
    })
    if (res.ok) {
      const data = await res.json()
      feedbackContent.value = data.feedback
      showReviewModal.value = true
    } else {
      console.error('Failed to get AI feedback', res.statusText)
      feedbackContent.value = 'Failed to get AI feedback.'
      showReviewModal.value = true
    }
  } catch (error) {
    console.error('Error getting AI feedback:', error)
    feedbackContent.value = 'Error getting AI feedback.'
    showReviewModal.value = true
  }
}

const openWeeklyGoalSettingModal = () => {
  weeklyGoalSettingModal.value.openModal()
}
</script>

<style scoped>
.calendar-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
}
</style>
