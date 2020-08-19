class AddAttributesToCountries < ActiveRecord::Migration[6.0]
  def change
    add_column :countries, :country_api_id, :string
    add_column :countries, :score, :float
    add_column :countries, :snippet, :string
  end
end
