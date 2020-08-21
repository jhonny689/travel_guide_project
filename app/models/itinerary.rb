class Itinerary < ActiveRecord::Base
    belongs_to :trip
    belongs_to :country

    def self.create_by_city(city, country, start, fin, trip)
        start_date = Date.parse(start)
        fin_date = Date.parse(fin)
        #city.country = Country.find_by(country_api_id: country.country_api_id) ? Country.find_by(country_api_id: country.country_api_id) : country
        #binding.pry
        binding.pry
        if User.find(User.logged_in_user).trips.find(trip.id).countries.find_by(country_api_id: country.country_api_id)
            city.country_id =  User.find(User.logged_in_user).trips.find(trip.id).countries.find_by(country_api_id: country.country_api_id).id 
        else
            # db_country = Country.new_from_api(country)
            country.save
            city.country_id = country.id
        end
        city.save
        Itinerary.create(country_id: city.country_id, itinerary_start: start_date, itinerary_end: fin_date, trip_id: trip.id)
    end

    def change_dates(start, fin)
        self.itinerary_start = start
        self.itinerary_end = fin
        self
    end

    # def delete_by_location(loc)
    #     if self.country == loc
    #         self.destroy
    #     elsif self.country.cities.any?(loc)
    #         self.destroy
    #     end
    # end

    # def sefl.find_by_city

    def self.find_by_loc_and_name(loc, name)
        name.all_itineraries.find{|e|e.country = loc}
    end

end