require 'rest-client'
require 'json'
require 'pry'

class CLI

    def start
        puts "welcome..."
        #users_response = RestClient.get("http://triposo.com/api/20200803/location.jason?id=Amsterdam&fields=all")
        #users_data = JSON.parse(users_response)
        test_request = RestClient::Request.execute(
            :method =>:get,
            :url => "https://www.triposo.com/api/20200803/location.json?part_of=France&tag_labels=city&count=10 id=Netherlands&fields=all",
            :headers => {
                "X-Triposo-Account" => "Q38FBTV2",
                "X-Triposo-Token" => "uaznpssyz097l7lib5duum5ccr8u1bt0"
            }
        )
        test_data = JSON.parse(test_request)
        binding.pry
    end
end