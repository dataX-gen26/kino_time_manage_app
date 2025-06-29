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
import { format, parseISO } from 'date-fns'

const calendar = useCalendarStore()
const categoriesStore = useCategoriesStore()

const showModal = ref(false)
const form = ref({
  content: '',
  category_id: null,
  start_time: '',
  end_time: '',
  is_problem: false,
})

const categoryOptions = computed(() => {
  return categoriesStore.categories.map(cat => ({ value: cat.id, text: cat.name }))
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
    }
  } else {
    resetForm()
  }
  showModal.value = true
}

const saveActual = async () => {
  if (form.value.id) {
    await calendar.updateActual(form.value.id, form.value)
  } else {
    await calendar.createActual(form.value)
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
  }
}

onMounted(() => {
  categoriesStore.fetchCategories()
})

defineExpose({ openModal })
</script>
