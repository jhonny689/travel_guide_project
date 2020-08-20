require 'pry'
class User < ActiveRecord::Base
    has_many :trips

    def create_trip(name)
        Trip.create(user_id: self, name: name)
    end

    def create_trip_with_itinerary(name, start, fin)
        trip = Trip.find_or_create_by(user_id: self, completed?: false, name: name)
        Itinerary.create(trip_id: trip.id, country_id: loc_response.id, itinerary_start: start, itinerary_end: fin)
        trip.sort_dates
    end

    def checkout_trip(trip)
        trip.trip_finalize
    end
    
    def all_itineraries
        trips.collect{|e|e.itineraries}.flatten
    end

    def all_countries 
        all_itineraries.map{|e|e.country}
    end

    def all_cities
        all_countries.map{|e|e.cities}.flatten
    end

    def all_activities
        trips.map{|e|e.activities}.flatten
    end

    def all_attractions
        trips.map{|e|e.attractions}.flatten
    end

    def update_trip_user(location, start, finish, trip)
       trip.update_trip(location, start, finish)
    end

    def remove_destination(destination)
        correct_it = Itinerary.find_by_loc_and_name(destination, self)
        Itinerary.destroy(correct_it.id)
        self.all_itineraries
    end

end