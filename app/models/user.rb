class User < ActiveRecord::Base

  before_save :stop_admin_deficit

  acts_as_authentic do |auth|
    auth.login_field = "login"
  end 

  def is_admin?
    if self.admin
      self.admin
    else
      false
    end
  end

  def stop_admin_deficit
    if  self.admin == false and (User.all(:conditions => ['admin = 1']) - [self]).count == 0
      self.errors.add(:base, "You can not stop the last admin user being an admin.")
      return false
    end
  end

end
