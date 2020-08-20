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
        self.display
        while true do
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
        puts "The #{self.name}, has a score of #{self.score}"
        puts "The #{self.snippet}"
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
    
end