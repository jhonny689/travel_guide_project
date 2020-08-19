class Search

    ## search.lookup_country_by_name allows you to query the API for a country
    ## the api response will have the country name, id, score and snippet
    ## and it returns an object of type Country with all the relevant data

    def self.lookup_country_by_name(prompt)
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
            Country.new_from_api(api_resp["results"][0])
        else
            # tell the user his query didn't return any result
            puts "Are you sure the country you are looking for is on earth!? Try again."
        end
    end

    def self.lookup_city_by_name(prompt)
        # ask for user's input
        city = prompt.ask("What City is your next destination? ")

        # Build your api query url
        url_query = "https://www.triposo.com/api/20200803/location.json?"
        tag_labels = "tag_labels=city"
        annotate = "annotate=trigram:#{city}"
        trigram = "trigram=>=0.8"
        fields="fields=id,coordinates,score,country_id,properties,name,snippet,part_of"
        order_by="order_by=-trigram"
        url_query += tag_labels +"&"+ annotate +"&"+ trigram +"&"+ fields +"&"+ order_by
        api_resp = self.execute(url_query)
        
        # study the API response and act correspondingly
        if self.single_api_result?(api_resp["results"])
            # create city object
            City.create_from_api(api_resp["results"][0])
        elsif self.many_api_results?(api_resp["results"])
            # ask for more details to narrow the search
            found_city = self.narrow_city_lookup(prompt, api_resp["results"])
            City.create_from_api(found_city)
        else
            # tell the user this city doesn't exist yet
            puts "Sorry, the city you are looking for is fictional, try later... "
        end
        binding.pry
    end

    # def self.lookup_city_by_name_and_country(prompt = nil, city_name = nil, country_id = nil)
    #     if prompt
    #         country = self.lookup_country_by_name(prompt.ask("What Country is your next destination? "))
    #         country_id = country.country_api_id
    #         city_name = prompt.ask("What City is your next destination? ")
    #     else

    #     end

    # end


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