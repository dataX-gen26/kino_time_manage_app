import { defineStore } from 'pinia'
import * as actualsApi from '@/api/actuals'

export const useActualsStore = defineStore('actuals', () => {
  const createActual = async (actualData) => {
    try {
      const response = await actualsApi.createActual(actualData)
      // 成功したら calendarStore の actuals を更新するなどの処理が必要になる
      return response.data
    } catch (error) {
      console.error('Failed to create actual:', error)
      throw error
    }
  }

  const updateActual = async (id, actualData) => {
    try {
      const response = await actualsApi.updateActual(id, actualData)
      return response.data
    } catch (error) {
      console.error('Failed to update actual:', error)
      throw error
    }
  }

  const deleteActual = async (id) => {
    try {
      await actualsApi.deleteActual(id)
    } catch (error) {
      console.error('Failed to delete actual:', error)
      throw error
    }
  }

  return {
    createActual,
    updateActual,
    deleteActual
  }
})
