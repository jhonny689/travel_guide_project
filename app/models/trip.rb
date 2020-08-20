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
                            attraction_obj.trip_id = selected.id
                            attraction_obj.save
                            #break
                        else
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
        self.display
        while true do
            selected = prompt.select("#{self.name} is the attraction you are looking for, what would you like to do? ") do |menu|
                menu.choice name:"Modify #{self.name}", value: 1
                menu.choice name:"Delete #{self.name}", value: 2
                menu.choice name:"Mark as Complete", value: 3
                menu.choice name:"Cancel", value:-1
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
            when -1
                return
            end
        end
    end

    def display
        ## TODO: Create method to display trip info...
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
        self.departure = prompt.ask("Want to update departure date? format:[dd/mm/yyyy] current: [#{self.departure}], new: ", default: self.departure, validate: /^([2][0][1-9][0-9])[-\/.](0[1-9]|[1][0-2])[-\/.](0[1-9]|[12][0-9]|3[01])/)
        self.return = prompt.ask("Want to update the return date? format:[dd/mm/yyyy] current:[#{self.return}], new: ", default: self.return, validate: /^([2][0][1-9][0-9])[-\/.](0[1-9]|[1][0-2])[-\/.](0[1-9]|[12][0-9]|3[01])/)
        self.save
    end

    def add_loc_trip(location=nil, start, finish)
   
        if location.class == City
            country = Country.new_from_api(Search.lookup_country_by_name(location.country_api_id))
            Itinerary.create_by_city(location, country, start, finish, self)
            self.sort_dates
        elsif location.class == Country
            location.save
            Itinerary.create(country: location, itinerary_start: start, itinerary_end: finish, trip: self)
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

    def add_new_activity(act)
        Activity.create(trip: self, activity_api_id: act.id)
    end


end

