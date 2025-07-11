import apiClient from './client'

export const getCategories = () => {
  return apiClient.get('/api/v1/categories')
}

export const createCategory = (categoryData) => {
  return apiClient.post('/api/v1/categories', { category: categoryData })
}

export const updateCategory = (id, categoryData) => {
  return apiClient.put(`/api/v1/categories/${id}`, { category: categoryData })
}

export const deleteCategory = (id) => {
  return apiClient.delete(`/api/v1/categories/${id}`)
}
