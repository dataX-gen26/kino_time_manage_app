<template>
  <BModal v-model="showModal" title="Actual Form" @hidden="resetForm">
    <BForm @submit.prevent="saveActual">
      <BFormGroup label="Content" label-for="content-input">
        <BFormInput id="content-input" v-model="form.content" required></BFormInput>
      </BFormGroup>

      <BFormGroup label="Category" label-for="category-select">
        <BFormSelect id="category-select" v-model="form.category_id" :options="categoryOptions" required></BFormSelect>
      </BFormGroup>

      <BFormGroup label="Start Time" label-for="start-time-input">
        <BFormInput id="start-time-input" v-model="form.start_time" type="datetime-local" required></BFormInput>
      </BFormGroup>

      <BFormGroup label="End Time" label-for="end-time-input">
        <BFormInput id="end-time-input" v-model="form.end_time" type="datetime-local" required></BFormInput>
      </BFormGroup>

      <BFormGroup>
        <BFormCheckbox v-model="form.is_problem">Is Problem?</BFormCheckbox>
      </BFormGroup>

      <hr>
      <h5>Weekly Goal Progress</h5>
      <BFormGroup label="Weekly Goal" label-for="weekly-goal-select">
        <BFormSelect id="weekly-goal-select" v-model="form.weekly_goal_id" :options="weeklyGoalOptions"></BFormSelect>
      </BFormGroup>
      <BFormGroup label="Progress Content" label-for="progress-content-textarea">
        <BFormTextarea id="progress-content-textarea" v-model="form.progress_content"></BFormTextarea>
      </BFormGroup>

      <div class="d-flex justify-content-end">
        <BButton type="submit" variant="primary">Save</BButton>
      </div>
    </BForm>
  </BModal>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useCalendarStore } from '../stores/calendar'
import { useCategoriesStore } from '../stores/categories'
import { useWeeklyGoalsStore } from '../stores/weeklyGoals'
import { format, parseISO } from 'date-fns'

const calendar = useCalendarStore()
const categoriesStore = useCategoriesStore()
const weeklyGoalsStore = useWeeklyGoalsStore()

const showModal = ref(false)
const form = ref({
  content: '',
  category_id: null,
  start_time: '',
  end_time: '',
  is_problem: false,
  weekly_goal_id: null,
  progress_content: '',
})

const categoryOptions = computed(() => {
  return categoriesStore.categories.map(cat => ({ value: cat.id, text: cat.name }))
})

const weeklyGoalOptions = computed(() => {
  return weeklyGoalsStore.weeklyGoals.map(goal => ({ value: goal.id, text: goal.title }))
})

const openModal = (actual = null) => {
  if (actual) {
    form.value = {
      id: actual.id,
      content: actual.content,
      category_id: actual.category_id,
      start_time: format(parseISO(actual.start_time), "yyyy-MM-dd'T'HH:mm"),
      end_time: format(parseISO(actual.end_time), "yyyy-MM-dd'T'HH:mm"),
      is_problem: actual.is_problem,
      weekly_goal_id: actual.weekly_goal_progresses?.[0]?.weekly_goal_id || null,
      progress_content: actual.weekly_goal_progresses?.[0]?.content || '',
    }
  } else {
    resetForm()
  }
  showModal.value = true
}

const saveActual = async () => {
  const actualData = {
    content: form.value.content,
    category_id: form.value.category_id,
    start_time: form.value.start_time,
    end_time: form.value.end_time,
    is_problem: form.value.is_problem,
  }

  let savedActual
  if (form.value.id) {
    savedActual = await calendar.updateActual(form.value.id, actualData)
  } else {
    savedActual = await calendar.createActual(actualData)
  }

  if (savedActual && form.value.weekly_goal_id && form.value.progress_content) {
    await weeklyGoalsStore.createWeeklyGoalProgress(
      form.value.weekly_goal_id,
      {
        actual_id: savedActual.id,
        progress_date: format(parseISO(form.value.start_time), 'yyyy-MM-dd'),
        content: form.value.progress_content,
      }
    )
  }
  showModal.value = false
}

const resetForm = () => {
  form.value = {
    content: '',
    category_id: null,
    start_time: '',
    end_time: '',
    is_problem: false,
    weekly_goal_id: null,
    progress_content: '',
  }
}

onMounted(() => {
  categoriesStore.fetchCategories()
  weeklyGoalsStore.fetchWeeklyGoals()
})

defineExpose({ openModal })
</script>
