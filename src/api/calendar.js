import apiClient from './client'

export const getEvents = (date) => {
  return apiClient.get(`/api/v1/calendar/events?date=${date}`)
}