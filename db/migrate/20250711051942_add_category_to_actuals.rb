class AddCategoryToActuals < ActiveRecord::Migration[8.0]
  def change
    add_reference :actuals, :category, null: false, foreign_key: true
  end
end
