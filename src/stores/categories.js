import { defineStore } from 'pinia'
import { ref } from 'vue'
import * as categoriesApi from '@/api/categories'

export const useCategoriesStore = defineStore('categories', () => {
  const categories = ref([])

  const fetchCategories = async () => {
    try {
      const response = await categoriesApi.getCategories()
      categories.value = response.data
    } catch (error) {
      console.error('Failed to fetch categories:', error)
      throw error
    }
  }

  return {
    categories,
    fetchCategories
  }
})
