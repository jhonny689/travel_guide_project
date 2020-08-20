class AddLocationIdToActivities < ActiveRecord::Migration[6.0]
  def change
    add_column :activities, :city_api_id, :string
  end
end
