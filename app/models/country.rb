class Country < ActiveRecord::Base
    has_many :cities
    has_many :itineraries
    has_many :trips, through: :itineraries

    def self.new_from_api(response)
        name = response["name"]
        country_api_id = response["id"]
        score = response["score"]
        snippet = response["snippet"]
        self.new(name: name, country_api_id: country_api_id, score: score, snippet: snippet)
    end

    def menu(prompt)
        while true do
            system "clear"
            CLI.display_header_menu
            self.display
            selected = prompt.select("#{self.name} is the country you are looking for, what would you like to do next?") do |menu|
                menu.choice name: "Add Country to Trip", value: 1
                menu.choice name: "Lookup cities within the country", value: 2
                menu.choice name: "Lookup top ten cities", value: 3
                menu.choice name: "Go back", value: 4
            end
            case selected
            when 1
                puts "TODO: Create function looking up the trips and returning them"
                Trip.list_all_user_trips(prompt: prompt, country_obj: self)
            when 2
                puts "TODO: Create function looking for a specific city in this country"
                city = self.lookup_cities(prompt)
                city.menu(prompt)
            when 3
                ##puts "TODO: Create function looking up top ten cities in the country"
                City.check_individually(self.top_ten_cities, prompt)
            when 4
                return
            end
        end
    end

    def display
        prepared_string = "Congratulations!! You landed in #{self.name};\n#{self.snippet}"
        display_box = TTY::Box.frame(width:100, height:9, padding: 1, align: :left) do
            prepared_string
        end
        print display_box
    end

    def lookup_cities(prompt)
        Search.lookup_city_by_name(prompt, self.country_api_id)
    end

    def top_ten_cities
        Search.lookup_top_ten_cities(self.country_api_id)
    end

    def self.country_names
        self.all.map{|e|e.name}
    end

    def city_names
        cities.map{|e|e.name}.flatten
    end

    def trip_country_menu(prompt)
        while true do
            selected = prompt.select("How would you like to edit your trip to #{self.name}") do |menu|
                menu.choice name: "Change the dates of your trip to #{self.name}", value: 1
                menu.choice name: "Remove #{self.name} from your trip", value: 2
                menu.choice name: "Return", value: 3
            end
            case selected
            when 1
                if prompt.yes?("Are you sure you want to change the dates of your trip to #{self.name}?") 
                    start_date = prompt.ask("Please enter your arrival date [yyyy/mm/dd],  current: [#{self.itineraries[0].itinerary_start}], new: ", default: self.itineraries[0].itinerary_start, validate: /^([2][0][1-9][0-9])[-\/.](0[1-9]|[1][0-2])[-\/.](0[1-9]|[12][0-9]|3[01])/)
                    fin_date = prompt.ask("Please enter your departure date [yyyy/mm/dd], current: [#{self.itineraries[0].itinerary_end}], new: ", default: self.itineraries[0].itinerary_end, validate: /^([2][0][1-9][0-9])[-\/.](0[1-9]|[1][0-2])[-\/.](0[1-9]|[12][0-9]|3[01])/)
                    self.itineraries[0].change_dates(start_date, fin_date)
                end
            when 2
                if prompt.yes?("Are you sure you want to delete the dates of your trip to #{self.name}?") 
                    binding.pry
                    self.itineraries.select{|e|e.country_id == self.id && e.city_id == nil}.each{|e|e.destroy}
                    self.destroy
                else return
                end
            when 3
                break
            end
        end
    end
    
end