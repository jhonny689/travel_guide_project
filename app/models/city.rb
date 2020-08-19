class City < ActiveRecord::Base
    belongs_to :country

    def self.create_from_api(api_city)
        name = api_city["name"]
        api_id = api_city["id"]
        country_api_id = api_city["country_id"]
        score = api_city["score"]
        latitude = api_city["coordinates"]["latitude"]
        longitude = api_city["coordinates"]["longitude"]
        population = api_city["properties"][0]["value"]
        snippet = api_city["snippet"]
    end
end