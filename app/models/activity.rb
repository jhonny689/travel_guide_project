class Activity < ActiveRecord::Base
    belongs_to :trip

    def self.new_from_api(api_activity)
        api_id = api_activity["id"]
        name = api_activity["name"]
        latitude = api_activity["coordinates"]["latitude"]
        longitude = api_activity["coordinates"]["longitude"]
        story = api_activity["intro"]
        #binding.pry
        index = api_activity["properties"].index{|property| property["key"] == "phone"}
        phone = index ? api_activity["properties"][index]["value"] : nil
        
        index = api_activity["properties"].index{|property| property["key"] == "address"}
        address = index ? api_activity["properties"][index]["value"] : nil
        
        index = api_activity["properties"].index{|property| property["key"] == "website"}
        website = index ? api_activity["properties"][index]["value"] : nil
        
        index = api_activity["properties"].index{|property| property["key"] == "price"}
        price = index ? api_activity["properties"][index]["value"] : nil
        
        index = api_activity["properties"].index{|property| property["key"] == "hours"}
        hours = index ? api_activity["properties"][index]["value"] : nil
        
        index = api_activity["properties"].index{|property| property["key"] == "bus"}
        bus = index ? api_activity["properties"][index]["value"] : nil
        
        index = api_activity["properties"].index{|property| property["key"] == "train"}
        train = index ? api_activity["properties"][index]["value"] : nil

        snippet = api_activity["snippet"]

        self.new(activity_api_id: api_id, name: name, latitude: latitude, longitude: longitude, story: story, phone: phone, address: address, website: website, price: price, hours: hours, bus: bus, train: train, snippet: snippet)
    end

    def self.list_activity_types(prompt, city)
        available_labels = Search.lookup_labels_in_city(city)
        while true
            answer = prompt.multi_select("Select the tags you want to search for: ") do |menu|
                menu.choice "Cancel", :cancel
                available_labels.each{|l| menu.choice l, l}
            end
            #binding.pry
            if answer.count == 0
                puts "You need to select at least one activity to search for, or cancel"
            elsif answer.include?(:cancel)
                break
            else
                return answer = answer.reduce(""){|res, label| res += "#{label}|"}.chop
            end
        end
    end

    def self.check_individually(array_activities, prompt)
        selected = prompt.select("select a city for more options: ") do |menu|
            array_activities.map{|city| menu.choice name: "#{city.name}", value: city}
            menu.choice name:"Cancel", value: -1
        end
        
        selected == -1 ? return : selected.menu(prompt)
    end

    def menu(prompt)
        self.display
        while true do
            selected = prompt.select("#{self.name} is the activity you are looking for, what would you like to do? ") do |menu|
                menu.choice name:"Add activity to Trip", value: 1
                menu.choice name:"Go back", value: 2
            end
            case selected
            when 1
                Trip.list_all_user_trips(prompt: prompt, activity_obj: self)
            when 2
                return
            end
        end
    end

    def display
        ## TODO fix display of activity
    end
end