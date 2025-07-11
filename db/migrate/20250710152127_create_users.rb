class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :google_id
      t.string :email
      t.string :name
      t.string :avatar_url
      t.text :access_token
      t.text :refresh_token

      t.timestamps
    end
  end
end
