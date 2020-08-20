class AddLocationIdToAttractions < ActiveRecord::Migration[6.0]
  def change
    add_column :attractions, :city_api_id, :string
  end
end
