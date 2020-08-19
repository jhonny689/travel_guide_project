require 'pry'
class User < ActiveRecord::Base
    has_many :trips

    def create_trip
        prompt = TTY::Prompt.new
        puts "Welcome to the Trip Creator, it will help you create your perfect vacation!"
        
        dep_response = prompt.ask("Please enter the day you would like to depart", convert: :date)
        ret_response = prompt.ask("Please enter the day you would like to return", convert: :date)
        binding.pry
        found_loc = nil
        until found_loc do
            loc_response = prompt.ask("Please enter a place you would like to visit")
            if self.countries.any?{|e|e.name == loc_response}
                found_loc = Country.find_by(name: loc_response)
            else puts "This location does not seem to exist, please enter a valid location"
            end
        end
        trip = Trip.find_or_create_by(user_id: self, completed?: false)
        Itinerary.create(trip_id: trip.id, country_id: found_loc.id, itinerary_start: dep_response, itinerary_end: ret_response) 
        trip.sort_dates
    end

    
    

end