class AddAttributesToAttractions < ActiveRecord::Migration[6.0]
  def change
    add_column :attractions, :name, :string
    add_column :attractions, :latitude, :float
    add_column :attractions, :longitude, :float
    add_column :attractions, :story, :string
    add_column :attractions, :phone, :string
    add_column :attractions, :address, :string
    add_column :attractions, :website, :string
    add_column :attractions, :price, :string
    add_column :attractions, :hours, :string
    add_column :attractions, :bus, :string
    add_column :attractions, :train, :string
    add_column :attractions, :snippet, :string
  end
end
