class User < ActiveRecord::Base
    has_many :trips
    @@logged_in_user = nil
    def full_name
        "#{self.f_name} #{self.l_name}"
    end

    def self.logged_in_user
        @@logged_in_user
    end
    def self.logged_in_user= (user)
        @@logged_in_user = user
    end
end