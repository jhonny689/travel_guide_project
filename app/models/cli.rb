

class CLI

    def start
        puts "welcome..."
        # test_request = RestClient::Request.execute(
        #     :method =>:get,
        #     :url => "https://www.triposo.com/api/20200803/location.json?part_of=France&tag_labels=city&count=10 id=Netherlands&fields=all",
        #     :headers => {
        #         "X-Triposo-Account" => ENV["TRIP_API_ACC"],
        #         "X-Triposo-Token" => ENV["TRIP_API_KEY"]
        #     }
        # )
        # test_data = JSON.parse(test_request)
        binding.pry
    end
end