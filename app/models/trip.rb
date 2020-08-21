class Trip < ActiveRecord::Base
    belongs_to :user
    has_many :activities
    has_many :attractions
    has_many :itineraries
    has_many :countries, through: :itineraries

    def self.list_all_user_trips(prompt: prompt, country_obj: nil, city_obj: nil, attraction_obj: nil, activity_obj: nil)
        while true do
            selected = prompt.select("choose one of the following trips") do |menu|
                User.find(User.logged_in_user).trips.each do |trip|
                    menu.choice name:"#{trip.name}", value: trip
                end
                menu.choice name:"Create new Trip", value: 0
                menu.choice name:"Cancel", value: -1
            end
            if selected == 0
                puts "TODO: Call method creating new Trip, and adding this country/city/attraction/activity to it"
                newTrip = User.find(User.logged_in_user).create_trip(prompt)
                # binding.pry
            elsif selected == -1
                return
            else
                ## puts "TODO: link this country to selected trip using trip id in selected variable"
                # binding.pry
                if(!country_obj && !city_obj && !attraction_obj && !activity_obj)
                    selected.menu(prompt)
                elsif country_obj
                    if prompt.yes?("Are you sure you want to add #{country_obj.name} to #{selected.name}? ")
                        start_date = prompt.ask("Please enter your arrival date [yyyy/mm/dd]", validate: /^([2][0][1-9][0-9])[-\/.](0[1-9]|[1][0-2])[-\/.](0[1-9]|[12][0-9]|3[01])/)
                        fin_date = prompt.ask("Please enter your departure date [yyyy/mm/dd]", validate: /^([2][0][1-9][0-9])[-\/.](0[1-9]|[1][0-2])[-\/.](0[1-9]|[12][0-9]|3[01])/)
                        selected.add_loc_trip(country_obj, start_date, fin_date)
                        break 
                    end
                elsif city_obj
                    # binding.pry
                    if prompt.yes?("Are you sure you want to add #{city_obj.name} to #{selected.name}? ") 
                        start_date = prompt.ask("Please enter your arrival date [yyyy/mm/dd]", validate: /^([2][0][1-9][0-9])[-\/.](0[1-9]|[1][0-2])[-\/.](0[1-9]|[12][0-9]|3[01])/)
                        fin_date = prompt.ask("Please enter your departure date [yyyy/mm/dd]", validate: /^([2][0][1-9][0-9])[-\/.](0[1-9]|[1][0-2])[-\/.](0[1-9]|[12][0-9]|3[01])/)
                        selected.add_loc_trip(city_obj, start_date, fin_date)
                        break
                    end
                elsif attraction_obj
                    if prompt.yes?("Are you sure you want to add #{attraction_obj.name} to #{selected.name}? ")
                        if User.find(User.logged_in_user).trips.find(selected.id).attractions.any?{|trip_attraction| trip_attraction.attraction_api_id == attraction_obj.attraction_api_id}
                            prompt.warn("Attraction #{attraction_obj.name} has been added to the same trip before, you cannot add it more than once")
                        elsif selected.all_cities.map{|city| city.api_id}.include?(attraction_obj.city_api_id)
                            binding.pry
                            attraction_obj.trip_id = selected.id
                            attraction_obj.save
                            #break
                        else
                            binding.pry
                            prompt.warn("This attraction does not belong to any city in this trip, kindly make sure to add the corresponding city first.")
                            #break
                        end
                        break
                    end
                elsif activity_obj
                    if prompt.yes?("Are you sure you want to add #{activity_obj.name} to #{selected.name}? ")
                        if User.find(User.logged_in_user).trips.find(selected.id).activities.any?{|trip_act|trip_act.activity_api_id == activity_obj.activity_api_id}
                            prompt.warn("Activity #{activity_obj.name} has been added to the same trip before, you cannot add it more than once")
                        elsif selected.all_cities.map{|city| city.api_id}.include?(activity_obj.city_api_id)
                            activity_obj.trip_id = selected.id
                            activity_obj.save
                        else
                            prompt.warn("This activity does not belong to any city in this trip, kindly make sure to add the corresponding city first.")
                        end
                        break 
                    end
                end
            end
        end
    end

    def menu(prompt)
        while true do
            if(!self.completed?)
                self.display
                selected = prompt.select("#{self.name} is the selected trip, what would you like to do? ") do |menu|
                    menu.choice name:"Modify #{self.name}", value: 1
                    menu.choice name:"Delete #{self.name}", value: 2
                    menu.choice name:"Mark as Complete", value: 3
                    menu.choice name:"Cancel", value:-1
                end
            else
                selected = prompt.select("We hope you enjoyed #{self.name}, what would you like to do next?") do |menu|
                    menu.choice name:"Display Completed #{self.name}", value: 9
                    menu.choice name:"Delete Completed #{self.name}", value: 2
                    menu.choice name:"Cancel", value:-1
                end
            end
            case selected
            when 1
                ## TODO Call update Trip
                self.trip_update(prompt)
                puts "Updated"
            when 2
                ## TODO Delete Trip
                if !prompt.no?("Are you sure you want to delete #{self.name}?, Warning: it will delete all related content...")
                    self.destroy
                end
                break
            when 3
                if prompt.yes?("Are you sure you want to mark #{self.name} as Complete?" )
                    self.trip_finalize
                end
                break
            when 9
                ## Display only for fun
                self.display
            when -1
                return
            end
        end
    end

    def display
        ## TODO: Create method to display trip info...
        prepared_string = "You are viewing Trip #{self.name}, this trip contains the following:\n"
        prepared_string += "Countries:"
        self.get_countries_array.each{|c| prepared_string += " #{c};"}
        prepared_string += "\nCities:"
        self.get_cities_array.each{|c| prepared_string += " #{c};"}
        prepared_string += "\nAttractions:"
        self.get_attractions_array.each{|c| prepared_string += " #{c};"}
        prepared_string += "\nActivities:"
        self.get_activities_array.each{|c| prepared_string += " #{c};"}

        display_box = TTY::Box.frame(width:100, height:9, padding: 1, align: :left) do
            prepared_string
        end
        print display_box
    end

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

    def all_cities
        self.countries.map{|e|e.cities}.flatten
    end

    def trip_finalize
        #binding.pry
        self.update(completed?: true)
    end 

    def trip_update(prompt)
        self.name = prompt.ask("Want to update the name? current: [#{self.name}], new: ", default:"#{self.name}")
        self.departure = prompt.ask("Want to update departure date? format:[yyyy/mm/dd] current: [#{self.departure}], new: ", default: self.departure, validate: /^([2][0][1-9][0-9])[-\/.](0[1-9]|[1][0-2])[-\/.](0[1-9]|[12][0-9]|3[01])/)
        self.return = prompt.ask("Want to update the return date? format:[yyyy/mm/dd] current:[#{self.return}], new: ", default: self.return, validate: /^([2][0][1-9][0-9])[-\/.](0[1-9]|[1][0-2])[-\/.](0[1-9]|[12][0-9]|3[01])/)
        self.save
    end

    def add_loc_trip(location=nil, start, finish)
   
        if location.class == City
            if self.all_cities.any?{|trip_city| trip_city.api_id == location.api_id}
                puts "#{location.name} already exists for #{self.name}, add it to a different trip maybe!?"
            else
                country = Country.new_from_api(Search.lookup_country_by_name(location.country_api_id))
                binding.pry
                Itinerary.create_by_city(location, country, start, finish, self)
                self.sort_dates
            end
        elsif location.class == Country
            if self.countries.any?{|trip_country| trip_country.country_api_id == location.country_api_id}
                puts "#{location.name} already exist for #{self.name}, add it to a different trip maybe!?"
            else
                location.save
                Itinerary.create(country: location, itinerary_start: start, itinerary_end: finish, trip: self)
                self.sort_dates
            end
        else 
            "Please enter a valid place you would like to visit"
        end
    end

    def list_acitivites_and_attractions
        acts = self.activities.map{|e|e.name}
        attracts = self.attractions.map{|e|e.name}
        acts.join(attracts).flatten
    end

    def add_new_activity(act)
        Activity.create(trip: self, activity_api_id: act.id)
    end

    def get_countries_array
        self.countries.map{|country| country.name}
    end
    def get_cities_array
        self.all_cities.map{|city| city.name}
    end
    def get_activities_array
        self.activities.map{|act| act.name}
    end
    def get_attractions_array
        # binding.pry
        self.attractions.map{|att| att.name}
    end

    def modify_components(prompt)
        while true do
            selected = prompt.select("#{self.name} is the selected trip, what would you like to do? ") do |menu|
                menu.choice name:"List countries", value: 1
                menu.choice name:"List cities", value: 2
                menu.choice name:"List activities", value: 3
                menu.choice name:"List attractions", value: 4
                menu.choice name:"Cancel", value:-1
                end
            case selected
            when 1
                select_country = prompt.select("Please choose a country destination to modify") do |menu|
                    menu.choice name: "Cancel", value: -1
                    self.countries.each do |nation|
                        menu.choice name: "Country: #{nation.name}, Arrival Date: #{nation.itineraries[0].itinerary_start} - Departure Date: #{nation.itineraries[0].itinerary_end}", value: nation
                    end  
                end
                if select_country!= -1
                    select_country.trip_country_menu(prompt)
                elsif select_country = 1
                    return
                else
                    return
                end
            when 2
                select_city = prompt.select("Please choose a city destination to modify") do |menu|
                    menu.choice name: "Cancel", value: -1
                    self.all_cities.each do |city|
                        menu.choice name: "City: #{city.name}, Arrival Date: #{city.country.itineraries[0].itinerary_start} - Departure Date: #{city.country.itineraries[0].itinerary_end}", value: city
                    end
                end
                if select_city!= -1
                    select_city.trip_city_menu(prompt)
                elsif select_city = 1
                    return
                else
                    return
                end
            when 3
                select_acts = prompt.select("Please choose an activity to modify") do |menu|
                menu.choice name: "Cancel", value: -1
                self.activities.each do |act|
                    menu.choice name: "#{act.name}"
                    end
                end
                if select_acts 
            when 4
                select_attracts = prompt.select("Please choose an activity to modify") do |menu|
                    menu.choice name: "Cancel", value: -1
                    self.attractions.each do |attracts|
                        menu.choice name: "#{attracts.name}"
                        end
                    end 
            when -1    
                break
            end
        end
    end

end

