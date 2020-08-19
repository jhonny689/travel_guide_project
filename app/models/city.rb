class City < ActiveRecord::Base
    belongs_to :country

    def self.city_names
        self.all.map{|e|e.name}
    end
end