class Country < ActiveRecord::Base
    has_many :cities
    has_many :itineraries
    has_many :trips, through: :itineraries

    def new_from_api(response)
        name = response[:name]
        country_api_id = response[:id]
        score = response[:score]
        snippet = response[:snippet]
        self.new(name: name, country_api_id: country_api_id, score: score, snippet: snippet)
    end

end