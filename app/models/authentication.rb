class Authentication < ActiveRecord::Base
    belongs_to :user

    def self.signin(prompt)
        username = prompt.ask("kindly enter your username: ")
        #  gets.chomp
        password = prompt.mask("kindly enter your password: ")
        #  gets.chomp
        auth = Authentication.new(username: username, password: password)
        auth_user = auth.authenticate
        if auth_user.size > 0
            return auth_user[0]
        else
            puts "Authentication error: wrong username and/or password; if you don't have an account please sign up"
        end
    end

    def self.signup(prompt)
        f_name = prompt.ask("what's your first name? ")
        l_name = prompt.ask("what's your last name? ")
        email = prompt.ask("what's your email address? ") do |q|
            q.validate(/^\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/, "Invalid email address")
        end
        new_user = User.new(f_name: f_name, l_name: l_name, email: email)
        invalid = true
        username = ""
        until !invalid do
            username = prompt.ask("What would you like your username to be? ") do |q|
                q.validate(/^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*$/, "Username shouldn't start or end with special caracters and can only contain alphanumerics combined with underscores and/or hyphens")
            end
            existing_user = Authentication.find_by(username: username)
            #binding.pry
            if existing_user == nil
                invalid = false
            else
                puts "This username is not available, please try a different one"
            end
        end
        password = prompt.mask("Please enter your password: ")
        new_user.save
        Authentication.create(user: new_user, username: username, password: password)
        new_user
    end

    def authenticate
        User.find(Authentication.where(username: self.username, password: self.password).pluck(:user_id))
    end
end