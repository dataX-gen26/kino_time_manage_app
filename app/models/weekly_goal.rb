class WeeklyGoal < ApplicationRecord
  belongs_to :user
  has_many :weekly_goal_progresses
end
