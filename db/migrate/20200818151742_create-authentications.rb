class Create-authentications < ActiveRecord::Migration[6.0]
  def change
    create_table :authentications do |t|
      t.integer :user_id
      t.string :username
      t.string :password
    end
  end
end
