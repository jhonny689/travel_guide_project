class Trip < ActiveRecord::Base
    has_many :activities
    has_many :attractions
    has_many :itineraries
    has_many :countries, through: :itineraries
    belongs_to :user


    def self.create_trip_by_city(name, city, start, fin)
        new_trip = Trip.create(name: name)
        Itinerary.create_by_city(city, start, fin, new_trip)
        new_trip.sort_dates
    end


    def sort_dates
        self.departure = self.itineraries.minimum("itinerary_start")
        self.return = self.itineraries.maximum("itinerary_end")
        self.save
        self
    end

    def trip_finalize
        self.update(completed?: true)
    end 

    def update_trip(location, start, finish)
        if City.all.include?(location)
            Itinerary.create_by_city(location, start, finish, self)
            self.sort_dates
        elsif Country.all.include?(location)
            Itinerary.create(country_id: location.id, itinerary_start: start, itinerary_end: finish, trip_id: self.id)
            self.sort_dates
        else 
            "Please enter a valid place you would like to visit"
        end
    end

    def list_acitivites_and_attractions
        acts = self.activities.map{|e|e.name}
        attracts = self.attractions.map{|e|e.name}
        acts.join(attracts).flatten
    end

    def add_new_activity
        Activity.create(trip_id: self.id)
    end


end

