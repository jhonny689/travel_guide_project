class Country < ActiveRecord::Base
    has_many :cities
    has_many :itineraries
    has_many :trips, through: :itineraries

    def self.country_names
        self.all.map{|e|e.name}
    end

    def city_names
        cities.map{|e|e.name}.flatten
    end
    
end