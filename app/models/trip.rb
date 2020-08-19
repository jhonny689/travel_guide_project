class Trip < ActiveRecord::Base
    has_many :activities
    has_many :attractions
    has_many :itineraries
    has_many :countries, through: :itineraries
    belongs_to :user


    def sort_dates
        self.departure = self.itineraries.minimum("itinerary_start")
        self.return = self.itineraries.maximum("itinerary_end")
        self.save
        self
    end

end

