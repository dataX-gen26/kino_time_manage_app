import { defineStore } from 'pinia'

export const useCategoriesStore = defineStore('categories', {
  state: () => ({
    categories: [],
  }),
  actions: {
    async fetchCategories() {
      try {
        const res = await fetch('/api/v1/categories')
        if (res.ok) {
          this.categories = await res.json()
        } else {
          console.error('Failed to fetch categories', res.statusText)
        }
      } catch (error) {
        console.error('Error fetching categories:', error)
      }
    },
    async createCategory(category) {
      try {
        const res = await fetch('/api/v1/categories', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ category }),
        })
        if (res.ok) {
          this.fetchCategories()
        } else {
          console.error('Failed to create category', res.statusText)
        }
      } catch (error) {
        console.error('Error creating category:', error)
      }
    },
    async updateCategory(id, category) {
      try {
        const res = await fetch(`/api/v1/categories/${id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ category }),
        })
        if (res.ok) {
          this.fetchCategories()
        } else {
          console.error('Failed to update category', res.statusText)
        }
      } catch (error) {
        console.error('Error updating category:', error)
      }
    },
    async deleteCategory(id) {
      try {
        const res = await fetch(`/api/v1/categories/${id}`, {
          method: 'DELETE',
        })
        if (res.ok) {
          this.fetchCategories()
        } else {
          console.error('Failed to delete category', res.statusText)
        }
      } catch (error) {
        console.error('Error deleting category:', error)
      }
    },
  },
})
