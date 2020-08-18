class CreateItineraries < ActiveRecord::Migration[6.0]
  def change
    create_table :itineraries do |t|
      t.integer :trip_id
      t.integer :country_id
      t.datetime :itinerary_start
      t.datetime :itinerary_end
    end
  end
end
