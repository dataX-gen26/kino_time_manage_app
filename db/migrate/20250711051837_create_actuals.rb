class CreateActuals < ActiveRecord::Migration[8.0]
  def change
    create_table :actuals do |t|
      t.string :title
      t.datetime :start_time
      t.datetime :end_time
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
