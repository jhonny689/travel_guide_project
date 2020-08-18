class CreateAttractions < ActiveRecord::Migration[6.0]
  def change
    create_table :attractions do |t|
      t.string :attraction_api_id
      t.integer :trip_id
    end
  end
end
