class User < ActiveRecord::Base
    has_many :trips

    def full_name
        "#{self.f_name} #{self.l_name}"
    end
end