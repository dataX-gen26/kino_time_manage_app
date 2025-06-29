class WeeklyGoalProgress < ApplicationRecord
  belongs_to :weekly_goal
  belongs_to :actual, optional: true
end
