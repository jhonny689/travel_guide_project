class Itinerary < ActiveRecord::Base
    belongs_to :trip
    belongs_to :country
end