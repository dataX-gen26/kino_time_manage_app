import { defineStore } from 'pinia'

export const useWeeklyGoalsStore = defineStore('weeklyGoals', {
  state: () => ({
    weeklyGoals: [],
  }),
  actions: {
    async fetchWeeklyGoals() {
      try {
        const res = await fetch('/api/v1/weekly_goals')
        if (res.ok) {
          this.weeklyGoals = await res.json()
        } else {
          console.error('Failed to fetch weekly goals', res.statusText)
        }
      } catch (error) {
        console.error('Error fetching weekly goals:', error)
      }
    },
    async createWeeklyGoal(weeklyGoal) {
      try {
        const res = await fetch('/api/v1/weekly_goals', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ weekly_goal: weeklyGoal }),
        })
        if (res.ok) {
          this.fetchWeeklyGoals()
        } else {
          console.error('Failed to create weekly goal', res.statusText)
        }
      } catch (error) {
        console.error('Error creating weekly goal:', error)
      }
    },
    async updateWeeklyGoal(id, weeklyGoal) {
      try {
        const res = await fetch(`/api/v1/weekly_goals/${id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ weekly_goal: weeklyGoal }),
        })
        if (res.ok) {
          this.fetchWeeklyGoals()
        } else {
          console.error('Failed to update weekly goal', res.statusText)
        }
      } catch (error) {
        console.error('Error updating weekly goal:', error)
      }
    },
    async deleteWeeklyGoal(id) {
      try {
        const res = await fetch(`/api/v1/weekly_goals/${id}`, {
          method: 'DELETE',
        })
        if (res.ok) {
          this.fetchWeeklyGoals()
        } else {
          console.error('Failed to delete weekly goal', res.statusText)
        }
      } catch (error) {
        console.error('Error deleting weekly goal:', error)
      }
    },
    async createWeeklyGoalProgress(weeklyGoalId, progress) {
      try {
        const res = await fetch(`/api/v1/weekly_goals/${weeklyGoalId}/weekly_goal_progresses`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ weekly_goal_progress: progress }),
        })
        if (res.ok) {
          // Optionally refetch weekly goals or update state locally
        } else {
          console.error('Failed to create weekly goal progress', res.statusText)
        }
      } catch (error) {
        console.error('Error creating weekly goal progress:', error)
      }
    },
  },
})
