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
                binding.pry
            elsif selected == -1
                return
            else
                ## puts "TODO: link this country to selected trip using trip id in selected variable"
                if(!country_obj && !city_obj && !attraction_obj && !activity_obj)
                    selected.menu(prompt)
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

    def update_trip(location=nil, start, finish)
        if City.all.include?(location)
            Itinerary.create_by_city(location, start, finish, self)
            self.sort_dates
        elsif Country.all.include?(location)
            Itinerary.create(country_id: location.id, itinerary_start: start, itinerary_end: finish, trip_id: self.id)
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
        Activity.create(trip_id: self.id, activity_api_id: act.id)
    end


end

