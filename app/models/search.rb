class Search

    ## search.lookup_country_by_name allows you to query the API for a country
    ## the api response will have the country name, id, score and snippet
    ## and it returns an object of type Country with all the relevant data

    def self.lookup_country_by_name(prompt)
        if prompt.class == String
            url_query = "https://www.triposo.com/api/20200803/location.json?"
            id = "id=#{prompt}"
            fields="fields=id,name,score,snippet"
            url_query += id +"&"+ fields
            api_resp = self.execute(url_query)
            return api_resp["results"][0]
        else    
            while true do
                # ask for user's input
                country = prompt.ask("What Country is your next destination? ")
                
                # Build your api query url
                url_query = "https://www.triposo.com/api/20200803/location.json?"
                tag_labels = "tag_labels=country"
                annotate = "annotate=trigram:#{country}"
                trigram = "trigram=>=0.3"
                fields="fields=id,name,score,snippet"
                order_by="order_by=-score"
                url_query += tag_labels +"&"+ annotate +"&"+ trigram +"&"+ fields +"&"+ order_by
                api_resp = self.execute(url_query)
                
                # Study the API response and act correspondingly
                if self.single_api_result?(api_resp["results"])
                    # create country object
                    return Country.new_from_api(api_resp["results"][0])
                else
                    # tell the user his query didn't return any result
                    answer = prompt.yes?("We are sorry, your search returned no results, do you want to try again?")
                    !answer ? return : ""
                end
            end
        end
    end

    def self.lookup_city_by_name(prompt, country=nil)
        while true do
            # ask for user's input
            city = prompt.ask("What City is your next destination? ")

            # Build your api query url
            url_query = "https://www.triposo.com/api/20200803/location.json?"
            tag_labels = "tag_labels=city"
            annotate = "annotate=trigram:#{city}"
            trigram = "trigram=>=0.8"
            fields="fields=id,coordinates,score,country_id,properties,name,snippet,part_of"
            order_by="order_by=-trigram"
            if country == nil
                url_query += tag_labels +"&"+ annotate +"&"+ trigram +"&"+ fields +"&"+ order_by
            else
                part_of = "part_of=#{country}"
                url_query += part_of +"&"+ tag_labels +"&"+ annotate +"&"+ trigram +"&"+ fields +"&"+ order_by
            end
            api_resp = self.execute(url_query)
            #binding.pry
            # study the API response and act correspondingly
            if self.single_api_result?(api_resp["results"])
                # create city object
                return City.new_from_api(api_resp["results"][0])
            elsif self.many_api_results?(api_resp["results"])
                # ask for more details to narrow the search
                found_city = self.narrow_city_lookup(prompt, api_resp["results"])
                if found_city 
                    return City.new_from_api(found_city)
                end
            else
                # tell the user this city doesn't exist yet
                answer = prompt.yes?("Sorry, We couldn't find the city you are looking for, try again?")
                !answer ? return : ""
            end
        end
    end

    def self.lookup_top_ten_cities(country_id)
        url_query = "https://www.triposo.com/api/20200803/location.json?"
        part_of = "part_of=#{country_id}"
        tag_labels = "tag_labels=city"
        count = "count=10"
        fields= "fields=id,coordinates,score,country_id,properties,name,snippet,part_of"
        order_by= "order_by=-score"

        url_query += part_of +"&"+ tag_labels +"&"+ count +"&"+ fields +"&"+ order_by
        top_cities = self.execute(url_query)
        #binding.pry
        to_return_cities = top_cities["results"].map do |api_city|
            City.new_from_api(api_city)
        end
    end

    def self.people_also_visited(city)
        url_query = "https://www.triposo.com/api/20200803/location.json?"
        part_of = "part_of=#{city.country_api_id}"
        annotate = "annotate=distance:45.47083,9.18815"
        distance = "distance=<=300000"
        also_visited = "also_visited=#{city.api_id}"
        count = "count=10"
        fields = "fields=id,coordinates,score,country_id,properties,name,snippet,part_of"
        order_by = "order_by=-also_visited_score"

        url_query += part_of +"&"+ annotate +"&"+ distance +"&"+ also_visited +"&"+ count +"&"+ fields +"&"+ order_by
        also_visited_cities = self.execute(url_query)
        #binding.pry
        to_return_cities = also_visited_cities["results"].map do |api_city|
            #binding.pry
            City.new_from_api(api_city)
        end
    end

    def self.lookup_attraction_by_name(prompt, location)
        attraction = prompt.ask("What's the name of the attraction you are looking for? ")
        url_query = "https://www.triposo.com/api/20200803/poi.json?"
        annotate = "annotate=trigram:#{attraction}"
        trigram = "trigram=>=0.3"
        location_id = "location_id=#{location}"
        count = "count=1"
        fields = "fields=id,location_id,name,coordinates,score,intro,properties,snippet"
        #exclude_fields = "exclude_fields=images,content,best_for,content"
        order_by = "order_by=-score"

        url_query += annotate +"&"+ trigram +"&"+ location_id +"&"+ count +"&"+ fields +"&"+ order_by
        attraction_resp = self.execute(url_query)
        attraction = Attraction.new_from_api(attraction_resp["results"][0])
    end

    def self.lookup_labels_in_city(city)
        url_query = "https://www.triposo.com/api/20200803/tag.json?"
        location_id = "location_id=#{city.api_id}"
        count = "count=50"
        order_by = "order_by=-score"

        url_query += location_id +"&"+ count +"&"+ order_by
        labels_resp = self.execute(url_query)
        labels_resp["results"].map{|label| label["label"]}
    end

    def self.lookup_activities_in_city(prompt, activity_labels, city)
        # while true do
            if activity_labels != ""
                url_query = "https://www.triposo.com/api/20200803/poi.json?"
                location_id="location_id=#{city.name}"
                tag_labels="tag_labels=#{activity_labels}"
                count = "count=50"
                fields = "fields=id,location_id,name,coordinates,score,intro,properties,snippet"
                order_by = "order_by=-score"
                #binding.pry
                url_query += location_id +"&"+ tag_labels +"&"+ count +"&"+ fields +"&"+ order_by
                api_resp = self.execute(url_query)
                #binding.pry
                return to_return_activities = api_resp["results"].map do |api_activity|
                    Activity.new_from_api(api_activity)
                end
            else
                if prompt.yes?("You need to select at least one activity, do you want to try again? ")

                end
            end
        # end
    end

    ## search.execute allows you to execute any api query you pass as argument
    ## so your serch methods don't have to worry about sending the request everytime
    ## your user tries a new search.

    def self.execute(query)
        test_request = RestClient::Request.execute(
            :method =>:get,
            :url => query,
            :headers => {
                "X-Triposo-Account" => ENV["TRIP_API_ACC"],
                "X-Triposo-Token" => ENV["TRIP_API_KEY"]
            }
        )
        File.open("export/temp.rb","w") do |f|
            f.write(JSON.parse(test_request))
        end
        test_data = JSON.parse(test_request)
    end

    private
    def self.single_api_result?(result)
        if result.count == 1
            true
        else
            false
        end
    end

    def self.many_api_results?(result)
        if result.count > 1
            true
        else
            false
        end
    end

    def self.narrow_city_lookup(prompt, result)
        
        ## Tell the user that his search returned more than one result
        puts "It seems your search returned more than one possible cities that belong to different countries"
        
        ## Ask the user to choose the country his city resides in
        country = prompt.select("kindly select the country in question here: ") do |menu|
            result.map do |city|
                #binding.pry
                city["country_id"]
            end.uniq.each do |country|
                menu.choice name: "#{country}", value: country
            end
            menu.choice name:"Cancel", value: -1
        end
        if country == -1
            return
        end
        ## Filter by your user's choice of country
        refined_cities = result.filter do |city|
            city["country_id"]==country
        end

        ## If the filter returned one city only return it
        if refined_cities.count == 1
            return refined_cities[0]
        ## If the filter still returned more than one city we need to filter again by region
        else
            
            ## Tell your user that his last filter wasn't enough
            puts "You are lucky #{country} has more than one #{result[0]["name"]}, "
            
            ## Ask the user to select his intended region from the list of regions we have
            part_of = prompt.select("choose yours: ") do |menu|
                refined_cities.map do |city|
                    city["part_of"][0]
                end.each do |region|
                    menu.choice name: "#{region}", value: region
                end
                menu.choice name: "Cancel", value: -1
            end
            if part_of == -1
                return
            end
            ## Filter by region selected by the user
            theCity = refined_cities.find do |city|
                city["part_of"].include?(part_of)
            end

            ## Return the city the user narrowed with his search
            return theCity
        end
    end
end