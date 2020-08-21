class CLI
    def start
        prompt = TTY::Prompt.new
        logged_in_user = nil
        until logged_in_user do
            logged_in_user = home_page_functionality(prompt)
            User.logged_in_user = logged_in_user
            #binding.pry
        end
        if logged_in_user
            dashboard_functionality(logged_in_user, prompt)
        end
    end

    def home_page_functionality(prompt)
        # while true do
            system "clear"
            box = TTY::Box.frame(width:100, height:9, padding: 2.5, align: :center) do
                "Welcome to your personal portal to the whole world...\n"+
                "We aim to make your tourism experience easier..."
            end
            print box
            selected = prompt.select("What would you like to do?") do |menu|
                menu.choice name: "Sign in",  value: 1
                menu.choice name: "Sign up", value: 2
                menu.choice name: "Exit",  value: 3
                menu.choice name: "test", value: 4
            end
            case selected
            when 1
                logged_in_user = Authentication.signin(prompt)
            when 2
                puts "create sign up method"
                new_user = Authentication.signup(prompt)
                select_option = prompt.yes?("Your user has been created, would you like to sign in?")
                #binding.pry
                if select_option == true
                    logged_in_user = new_user
                end
            when 3
                return exit!
            when 4
                binding.pry
            end
        # end
    end

    def dashboard_functionality(logged_in_user, prompt)
        while true do
            system "clear"
            self.class.display_header_menu
            selected = prompt.select("What would you like to do?") do |menu|
                menu.choice name: "Go To Trips",  value: 1
                menu.choice name: "Go To Search", value: 2
                menu.choice name: "Sign out",  value: 3
            end
            case selected
            when 1
                Trip.list_all_user_trips(prompt: prompt)
            when 2
                go_to_search(prompt)
            when 3
                logged_in_user = nil
                puts "Sorry to see you leave..."
                start
            end
        end
    end

    def go_to_search(prompt)
        while true do
            system "clear"
            self.class.display_header_menu
            selected = prompt.select("Kindly select one of the below options") do |menu|
                menu.choice name: "Lookup a Country by name", value: 1
                menu.choice name: "Lookup a City by name", value: 2
                # menu.choice name: "Coming soon...", value: 3
                # menu.choice name: "Coming soon...", value: 4
                menu.choice name: "Go back", value: 5
            end
            case selected
            when 1
                country = Search.lookup_country_by_name(prompt)
                country ? country.menu(prompt) : ""
            when 2
                city = Search.lookup_city_by_name(prompt)
                city ? city.menu(prompt) : ""
            when 3
                puts "this feature is yet to be developed..."
            when 4
                puts "this feature is yet to be developed..."
            when 5
                return
            end
        end
    end
    def self.display_header_menu
        ## TODO: Create method to display trip info...
        box = TTY::Box.frame(width:100, height:9, padding: 3, align: :center) do
            "Welcome #{User.find(User.logged_in_user).full_name}, we are at your service..."
        end
        print box
    end
end