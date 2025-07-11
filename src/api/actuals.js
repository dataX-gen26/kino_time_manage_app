import apiClient from './client'

export const getActuals = (date) => {
  return apiClient.get(`/api/v1/actuals?date=${date}`)
}

export const createActual = (actualData) => {
  return apiClient.post('/api/v1/actuals', { actual: actualData })
}

export const updateActual = (id, actualData) => {
  return apiClient.put(`/api/v1/actuals/${id}`, { actual: actualData })
}

export const deleteActual = (id) => {
  return apiClient.delete(`/api/v1/actuals/${id}`)
}
