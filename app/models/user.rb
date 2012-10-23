class User < ActiveRecord::Base

  acts_as_authentic do |auth|
    
    auth.login_field = "login"
 
  end 

  def is_admin?

  end

end
