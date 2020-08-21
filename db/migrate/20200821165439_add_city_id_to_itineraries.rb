class AddCityIdToItineraries < ActiveRecord::Migration[6.0]
  def change
    add_column :itineraries, :city_id, :integer
  end
end
