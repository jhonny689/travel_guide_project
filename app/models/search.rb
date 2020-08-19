class Search
    def self.search_country_by_name(prompt)
        destination = prompt.ask("what is your destination")
        url_query = "https://www.triposo.com/api/20200803/location.json?"
        tag_labels = "tag_labels=country"
        annotate = "annotate=trigram:#{destination}"
        trigram = "trigram=>=0.3"
        fields="fields=id,name,score,snippet"
        order_by="order_by=-score"
        url_query += tag_labels +"&"+ annotate +"&"+ trigram +"&"+ fields +"&"+ order_by
        api_resp = self.execute(url_query)
        Country.new_from_api(api_resp[:results][0])
    end

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
        #binding.pry
        test_data = JSON.parse(test_request)
    end
end