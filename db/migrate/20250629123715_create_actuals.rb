class CreateActuals < ActiveRecord::Migration[8.0]
  def change
    create_table :actuals do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.text :content
      t.boolean :is_problem

      t.timestamps
    end
  end
end
