class CreateTrips < ActiveRecord::Migration[6.0]
  def change
    create_table :trips do |t|
      t.integer :user_id
      t.date :departure
      t.date :return
      t.boolean :completed?, default: false
    end
  end
end
