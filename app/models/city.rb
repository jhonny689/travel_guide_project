class City < ActiveRecord::Base
    belongs_to :country

    def self.new_from_api(api_city)
        name = api_city["name"]
        api_id = api_city["id"]
        country_api_id = api_city["country_id"]
        score = api_city["score"]
        latitude = api_city["coordinates"]["latitude"]
        longitude = api_city["coordinates"]["longitude"]
        #binding.pry
        population = api_city["properties"].count > 0 ? api_city["properties"][0]["value"] : nil
        snippet = api_city["snippet"]
        self.new(name: name, api_id: api_id, country_api_id: country_api_id, score: score, latitude: latitude, longitude: longitude, population: population, snippet: snippet)
    end

    def menu(prompt)
        while true do
            system "clear"
            CLI.display_header_menu
            self.country.display
            self.display
            selected = prompt.select("#{self.name} is the city you are looking for, what would you like to do next?") do |menu|
                menu.choice name: "Add City to Trip", value: 1
                menu.choice name: "Lookup other cities people visited", value: 2
                menu.choice name: "Lookup attractions in #{self.name}", value: 3
                menu.choice name: "Lookup activities in #{self.name}", value: 4
                menu.choice name: "Go back", value: -1
            end
            case selected
            when 1
                #puts "TODO: Create function looking up trips and adding city to chosen trip"
                Trip.list_all_user_trips(prompt: prompt, city_obj: self)
            when 2 
                #puts "TODO: Create function returning a list of cities that people who visited this city also visited"
                self.class.check_individually(self.people_also_visited, prompt)
            when 3
                #puts "TODO: Create function returning a specific attraction in the city"
                attraction = self.lookup_attraction_by_name(prompt)
                attraction ? attraction.menu(prompt) : ""
            when 4
                activity_label = Activity.list_activity_types(prompt, self)
                if !activity_label
                    ""
                else
                    Activity.check_individually(self.lookup_activities_in_city(prompt, activity_label, self), prompt)
                end
            when -1
                return
            end
        end
    end
    def display
        prepared_string = "Congratulations!! You landed in #{self.name}; city of #{self.country_api_id}\nKnown as #{self.snippet}.\n#{self.name} has a population of #{self.population}.\n#{self.name} is located at #{self.latitude} latitude and #{longitude} longitude.\n#{self.name} score is #{self.score}"
        display_box = TTY::Box.frame(width:100, height:9, padding: 0.5, align: :left) do
            prepared_string
        end
        print display_box
    end

    def people_also_visited
        Search.people_also_visited(self)
    end

    def self.check_individually(array_cities, prompt)
        selected = prompt.select("select a city for more options: ") do |menu|
            array_cities.map{|city| menu.choice name: "#{city.name}", value: city}
            menu.choice name:"Cancel", value: -1
        end
        
        selected == -1 ? return : selected.menu(prompt)
    end

    def lookup_attraction_by_name(prompt)
        Search.lookup_attraction_by_name(prompt, self.api_id)
    end

    def lookup_activities_in_city(prompt, activity_labels, city)
        Search.lookup_activities_in_city(prompt, activity_labels, city)
    end
    def self.city_names
        self.all.map{|e|e.name}
    end

    def trip_city_menu(prompt)
        while true do
            selected = prompt.select("How would you like to edit your trip to #{self.name}") do |menu|
                menu.choice name: "Change the dates of your trip to #{self.name}", value: 1
                menu.choice name: "Remove #{self.name} from your trip", value: 2
                menu.choice name: "Return", value: 3
            end
            case selected
            when 1
                if prompt.yes?("Are you sure you want to change the dates of your trip to #{self.name}?") 
                    start_date = prompt.ask("Please enter your arrival date [yyyy/mm/dd], current: [#{Itinerary.find_by(city_id: self.id).itinerary_start}], new: ", default: Itinerary.find_by(city_id: self.id).itinerary_start, validate: /^([2][0][1-9][0-9])[-\/.](0[1-9]|[1][0-2])[-\/.](0[1-9]|[12][0-9]|3[01])/)
                    fin_date = prompt.ask("Please enter your departure date [yyyy/mm/dd], current: [#{Itinerary.find_by(city_id: self.id).itinerary_end}], new: ", default: Itinerary.find_by(city_id: self.id).itinerary_end, validate: /^([2][0][1-9][0-9])[-\/.](0[1-9]|[1][0-2])[-\/.](0[1-9]|[12][0-9]|3[01])/)
                    self.country.itineraries[0].change_dates(start_date, fin_date)
                end
            when 2
                # binding.pry
                if prompt.yes?("Are you sure you want to delete the dates of your trip to #{self.name}?")
                    self.country.itineraries.find_by(city_id: self.id).destroy
                    self.destroy
                else return
                end
            when 3
                break
            end
        end
    end
end