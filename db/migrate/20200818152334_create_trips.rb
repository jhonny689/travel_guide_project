class CreateTrips < ActiveRecord::Migration[6.0]
  def change
    create_table :trips do |t|
      t.integer :user_id
      t.datetime :departure
      t.datetime :return
    end
  end
end
