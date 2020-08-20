class Itinerary < ActiveRecord::Base
    belongs_to :trip
    belongs_to :country

    def self.create_by_city(c, start, fin, trip)
        start_date = Date.parse(start)
        fin_date = Date.parse(fin)
        Itinerary.create(country_id: c.country_id, itinerary_start: start_date, itinerary_end: fin_date, trip_id: trip.id)
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