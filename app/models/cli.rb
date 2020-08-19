

class CLI

    def start
        puts "Welcome to your portal to the world..."
        puts "We aim to make your tourism experience easier..."        
        prompt = TTY::Prompt.new
        logged_in_user = nil
        until logged_in_user do
            selected = prompt.select("What would you like to do?") do |menu|
                menu.choice name: "Sign in",  value: 1
                menu.choice name: "Sign up", value: 2
                menu.choice name: "Exit",  value: 3
                menu.choice name: "PRY", value: 4
              end
            case selected
            when 1
                logged_in_user = Authentication.signin(prompt)
            when 2
                puts "create sign up method"
                new_user = Authentication.signup(prompt)
                select_option = prompt.yes?("Your user has been created, would you like to sign in?")
                binding.pry
                if select_option == true
                    logged_in_user = new_user
                end
            when 3
                break;
            when 4
                Search.search_country_by_name(prompt)
            end
        end
        if logged_in_user
            puts "welcome #{logged_in_user.full_name}, we are at your service..."
            selected = prompt.select("What would you like to do?") do |menu|
                menu.choice name: "See Trips",  value: 1
                menu.choice name: "Sign up", value: 2
                menu.choice name: "Exit",  value: 3
                menu.choice name: "PRY", value: 4
              end


        end
    end
end