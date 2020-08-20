class AddAttributesToActivities < ActiveRecord::Migration[6.0]
  def change
    add_column :activities, :name, :string
    add_column :activities, :latitude, :float
    add_column :activities, :longitude, :float
    add_column :activities, :story, :string
    add_column :activities, :phone, :string
    add_column :activities, :address, :string
    add_column :activities, :website, :string
    add_column :activities, :price, :string
    add_column :activities, :hours, :string
    add_column :activities, :bus, :string
    add_column :activities, :train, :string
    add_column :activities, :snippet, :string
  end
end
