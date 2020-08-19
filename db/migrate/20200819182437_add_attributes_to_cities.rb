class AddAttributesToCities < ActiveRecord::Migration[6.0]
  def change
    add_column :cities, :api_id, :string
    add_column :cities, :country_api_id, :string
    add_column :cities, :score, :float
    add_column :cities, :latitude, :float
    add_column :cities, :longitude, :float
    add_column :cities, :population, :double
    add_column :cities, :snippet, :string
  end
end
