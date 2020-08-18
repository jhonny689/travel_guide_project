class Trip < ActiveRecord::Base
    has_many :activities
    has_many :attractions
    has_many :itineraries
    has_many :countries, through: :itineraries
end