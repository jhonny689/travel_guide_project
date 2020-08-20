class Trip < ActiveRecord::Base
    belongs_to :user
    has_many :activities
    has_many :attractions
    has_many :itineraries
    has_many :countries, through: :itineraries

    def self.list_all_user_trips(prompt: prompt, country_obj: nil, city_obj: nil, attraction_obj: nil, activity_obj: nil)
        selected = prompt.select("choose one of the following trips") do |menu|
            User.logged_in_user.trips.each do |trip|
                menu.choice name:"#{trip.name}", value: trip.id
            end
            menu.choice name:"Create new Trip", value: 0
            menu.choice name:"Cancel", value: -1
        end
        if selected == 0
            puts "TODO: Call method creating new Trip, and adding this country/city/attraction/activity to it"
        elsif selected == -1
            return
        else
            puts "TODO: link this country to selected trip using trip id in selected variable"
        end
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
        self.update(completed?: true)
    end 

    def update_trip(location, start, finish)
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

