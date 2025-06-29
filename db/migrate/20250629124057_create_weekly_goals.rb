class CreateWeeklyGoals < ActiveRecord::Migration[8.0]
  def change
    create_table :weekly_goals do |t|
      t.references :user, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.string :title
      t.text :description
      t.string :status

      t.timestamps
    end
  end
end
