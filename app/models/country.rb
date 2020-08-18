class Country < ActiveRecord::Base
    has_many :cities
    has_many :itineraries
    has_many :trips, through: :itineraries
end