<template>
  <BModal v-model="showModal" title="Weekly Goal Setting" @hidden="resetForm">
    <BForm @submit.prevent="saveWeeklyGoal">
      <BFormGroup label="Title" label-for="title-input">
        <BFormInput id="title-input" v-model="form.title" required></BFormInput>
      </BFormGroup>

      <BFormGroup label="Description" label-for="description-textarea">
        <BFormTextarea id="description-textarea" v-model="form.description"></BFormTextarea>
      </BFormGroup>

      <BFormGroup label="Start Date" label-for="start-date-input">
        <BFormInput id="start-date-input" v-model="form.start_date" type="date" required></BFormInput>
      </BFormGroup>

      <BFormGroup label="End Date" label-for="end-date-input">
        <BFormInput id="end-date-input" v-model="form.end_date" type="date" required></BFormInput>
      </BFormGroup>

      <BFormGroup label="Status" label-for="status-select">
        <BFormSelect id="status-select" v-model="form.status" :options="statusOptions" required></BFormSelect>
      </BFormGroup>

      <div class="d-flex justify-content-end">
        <BButton type="submit" variant="primary">Save</BButton>
      </div>
    </BForm>
  </BModal>
</template>

<script setup>
import { ref } from 'vue'
import { useWeeklyGoalsStore } from '../stores/weeklyGoals'
import { format, startOfWeek, endOfWeek } from 'date-fns'

const weeklyGoalsStore = useWeeklyGoalsStore()

const showModal = ref(false)
const form = ref({
  title: '',
  description: '',
  start_date: format(startOfWeek(new Date(), { weekStartsOn: 1 }), 'yyyy-MM-dd'),
  end_date: format(endOfWeek(new Date(), { weekStartsOn: 1 }), 'yyyy-MM-dd'),
  status: 'active',
})

const statusOptions = [
  { value: 'active', text: 'Active' },
  { value: 'completed', text: 'Completed' },
  { value: 'archived', text: 'Archived' },
]

const openModal = (goal = null) => {
  if (goal) {
    form.value = {
      id: goal.id,
      title: goal.title,
      description: goal.description,
      start_date: goal.start_date,
      end_date: goal.end_date,
      status: goal.status,
    }
  } else {
    resetForm()
  }
  showModal.value = true
}

const saveWeeklyGoal = async () => {
  if (form.value.id) {
    await weeklyGoalsStore.updateWeeklyGoal(form.value.id, form.value)
  } else {
    await weeklyGoalsStore.createWeeklyGoal(form.value)
  }
  showModal.value = false
}

const resetForm = () => {
  form.value = {
    title: '',
    description: '',
    start_date: format(startOfWeek(new Date(), { weekStartsOn: 1 }), 'yyyy-MM-dd'),
    end_date: format(endOfWeek(new Date(), { weekStartsOn: 1 }), 'yyyy-MM-dd'),
    status: 'active',
  }
}

defineExpose({ openModal })
</script>
