class Attraction < ActiveRecord::Base
    belongs_to :trip

    def self.new_from_api(api_att)
        api_id = api_att["id"]
        name = api_att["name"]
        latitude = api_att["coordinates"]["latitude"]
        longitude = api_att["coordinates"]["longitude"]
        story = api_att["intro"]
        #binding.pry
        index = api_att["properties"].index{|property| property["key"] == "phone"}
        phone = index ? api_att["properties"][index]["value"] : nil
        
        index = api_att["properties"].index{|property| property["key"] == "address"}
        address = index ? api_att["properties"][index]["value"] : nil
        
        index = api_att["properties"].index{|property| property["key"] == "website"}
        website = index ? api_att["properties"][index]["value"] : nil
        
        index = api_att["properties"].index{|property| property["key"] == "price"}
        price = index ? api_att["properties"][index]["value"] : nil
        
        index = api_att["properties"].index{|property| property["key"] == "hours"}
        hours = index ? api_att["properties"][index]["value"] : nil
        
        index = api_att["properties"].index{|property| property["key"] == "bus"}
        bus = index ? api_att["properties"][index]["value"] : nil
        
        index = api_att["properties"].index{|property| property["key"] == "train"}
        train = index ? api_att["properties"][index]["value"] : nil

        snippet = api_att["snippet"]

        self.new(attraction_api_id: api_id, name: name, latitude: latitude, longitude: longitude, story: story, phone: phone, address: address, website: website, price: price, hours: hours, bus: bus, train: train, snippet: snippet)
    end

    def menu(prompt)
        system "clear"
        while true do
            self.display
            selected = prompt.select("#{self.name} is the attraction you are looking for, what would you like to do? ") do |menu|
                menu.choice name:"Add attraction to Trip", value: 1
                menu.choice name:"Go back", value: -1
            end
            case selected
            when 1
                Trip.list_all_user_trips(prompt: prompt, attraction_obj: self)
            when -1
                return
            end
        end
    end

    def display
        ## TODO display the info of the attraction ##
        prepared_string = "Congratulations!! You found #{self.name}."
        prepared_string += "\n#{self.name} is located at #{self.latitude} latitude and #{longitude} longitude."
        prepared_string += "\n#{self.name} contact details are the following:"
        prepared_string += "\n- phone: #{self.phone}"
        prepared_string += "\n- address: #{self.address}"
        prepared_string += "\n- website: #{self.website}"
        prepared_string += "\n- price: #{self.price}"
        prepared_string += "\n- hours: #{self.hours}"


        display_box = TTY::Box.frame(width:100, height:10, padding: 0, align: :left) do
            prepared_string
        end
        print display_box
    end
end