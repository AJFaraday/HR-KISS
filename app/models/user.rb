class User < ActiveRecord::Base

  before_save :stop_admin_deficit

  belongs_to :line_manager, :foreign_key => 'line_manager_id', :class_name => 'User'
  has_many :subordinates, :foreign_key => 'line_manager_id', :class_name => 'User'

  validates_presence_of :line_manager_id
  validates_presence_of :name

  acts_as_authentic do |auth|
    auth.login_field = "login"
  end

  has_many :absences do

    # named_scope equivalents (seems standard for rails 3)
    def current
      all(:conditions => ['start_time < ? and end_time > ?', Time.now, Time.now], :order => "start_time ASC")
    end

    def past
      all(:conditions => ['end_time < ?', Time.now], :order => "start_time ASC")
    end

    def future
      all(:conditions => ['start_time > ?', Time.now], :order => "start_time ASC")
    end

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

  def absent?
    absences.current.any?
  end

  def present?
    !absent?
  end

end
