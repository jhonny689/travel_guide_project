class Trip < ActiveRecord::Base
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
end