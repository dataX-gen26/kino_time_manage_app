class CreateWeeklyGoalProgresses < ActiveRecord::Migration[8.0]
  def change
    create_table :weekly_goal_progresses do |t|
      t.references :weekly_goal, null: false, foreign_key: true
      t.references :actual, null: false, foreign_key: true
      t.date :progress_date
      t.text :content

      t.timestamps
    end
  end
end
