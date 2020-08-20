require 'pry'
class User < ActiveRecord::Base
    has_many :trips

    def create_trip
        prompt = TTY::Prompt.new
        puts "Welcome to the Trip Creator, it will help you create your perfect vacation!"
        loc_response = nil  
        until Country.all.any?{|e|e.name == loc_response} or City.all.any?{|e|e.name == loc_response}
            loc_response = prompt.ask("Please enter a valid place you would like to visit")
        end
        dep_response = prompt.ask("Please enter the day you would like to depart", convert: :date)
        ret_response = prompt.ask("Please enter the day you would like to return", convert: :date)
        trip = Trip.find_or_create_by(user_id: self, completed?: false)
        Itinerary.create(trip_id: trip.id, country_id: loc_response.id, itinerary_start: dep_response, itinerary_end: ret_response) 
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

    def all_activities
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