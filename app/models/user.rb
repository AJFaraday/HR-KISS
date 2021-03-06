class User < ActiveRecord::Base

  before_save :stop_admin_deficit

  belongs_to :line_manager, :foreign_key => 'line_manager_id', :class_name => 'User'
  has_many :subordinates, :foreign_key => 'line_manager_id', :class_name => 'User'

  validates_presence_of :line_manager_id
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_numericality_of :sick_day_allowance, :greater_than_or_equal_to => 0
  validates_numericality_of :holiday_allowance, :greater_than_or_equal_to => 0

  after_create :notify_user
  attr_accessor :skip_notification

  def notify_user
    unless skip_notification == true
      UserMailer.notify_new_user(self).deliver
    end
  end

  before_save :set_days

  has_many :flexes, :order => 'position DESC', :dependent => :destroy do

    def most_recent
      find_by_position_and_discarded maximum('position'), false
    end

    def for_timeline(limit=:all)
      if any?
        if limit and limit != :all
          result = Flex.find_by_sql("select * from flexes where user_id = #{self[0].user_id} order by position desc limit #{limit}")
        else
          result = Flex.find_by_sql("select * from flexes where user_id = #{self[0].user_id} order by position desc")
        end
        return result.reverse
      else
        return []
      end
    end

  end


  acts_as_authentic do |auth|
    auth.login_field = "login"
  end

  has_many :absences, :dependent => :destroy do

    def holidays_this_year(status=:all)
      if status.in?(['all', :all])
        all(:conditions => ["start_time >= ? and
                             end_time <= ? and
                             variety = 'Holiday'",
                            Date.today.beginning_of_year,
                            Date.today.end_of_year],
            :order => 'start_time ASC')
      else
        all(:conditions => ["start_time >= ? and
                             end_time <= ? and
                             variety = 'Holiday' and
                             status = ?",
                            Date.today.beginning_of_year,
                            Date.today.end_of_year,
                            status],
            :order => 'start_time ASC')
      end
    end

    def sick_days_this_year(status=:all)
      if status.in?(['all', :all])
        all(:conditions => ["start_time >= ? and
                             end_time <= ? and
                             variety = 'Sick Days'",
                            Date.today.beginning_of_year,
                            Date.today.end_of_year],
            :order => 'start_time ASC')

      else
        all(:conditions => ["start_time >= ? and
                             end_time <= ? and
                             variety = 'Sick Days' and
                             status = ?",
                            Date.today.beginning_of_year,
                            Date.today.end_of_year,
                            status],
            :order => 'start_time ASC')
      end
    end

    # named_scope equivalents (seems standard for rails 3)
    def current(status = nil)
      if status
        all(:conditions => ['start_time < ? and end_time > ? and status = ?',
                            Time.now, Time.now, status], :order => "start_time ASC")
      else
        all(:conditions => ['start_time < ? and end_time > ?', Time.now, Time.now], :order => "start_time ASC")
      end

    end

    def past(status=nil)
      if status
        all(:conditions => ['end_time < ? and status = ?', Time.now, status], :order => "start_time ASC")
      else
        all(:conditions => ['end_time < ?', Time.now], :order => "start_time ASC")
      end
    end

    def future(status=nil)
      if status
        all(:conditions => ['start_time > ? and status = ?', Time.now, status], :order => "start_time ASC")
      else
        all(:conditions => ['start_time > ?', Time.now], :order => "start_time ASC")
      end
    end

    def self.all_to_jquery
      all.collect { |absence| absence.to_jquery_attributes }.to_json.gsub('"', '')
    end

  end

  def absences_to_approve
    user_ids = self.subordinates.collect { |u| u.id }
    Absence.all(:conditions => ['user_id in (?) and status = "Pending"', user_ids],
                :order => 'start_time ASC')
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

  def set_days(save_results=false)
    # this years holidays
    holidays = absences.holidays_this_year('Approved').collect { |x| x.days }.sum
    sick_days = absences.sick_days_this_year('Approved').collect { |x| x.days }.sum
    if save_results
      update_attributes(:holiday_remaining => holiday_allowance - holidays,
                        :sick_days_remaining => sick_day_allowance - sick_days)
    else
      self.holiday_remaining = holiday_allowance - holidays
      self.sick_days_remaining = sick_day_allowance - sick_days
    end
  end

  def holiday_numbers
    ActiveSupport::SafeBuffer.new("<span #{'style="color:red;"' if holiday_remaining < 0}>#{holiday_remaining}</span>/#{holiday_allowance}")
  end

  def sick_day_numbers
    ActiveSupport::SafeBuffer.new("<span #{'style="color:red;"' if sick_days_remaining < 0}>#{sick_days_remaining}</span>/#{sick_day_allowance}")
  end


  def flex_time
    if flexes.most_recent
      negative = (flexes.most_recent.total_minutes + (flexes.most_recent.total_hours * 60)) < 0
      "#{'-' if negative}#{flexes.most_recent.total_hours.abs}:#{sprintf '%02d', flexes.most_recent.total_minutes.abs}"
    else
      '0:00'
    end
  end

  def flex(position)
    self.flexes.find_by_position position
  end

  def to_s
    self.name
  end

  def generated_colour
    gen_colour = name.bytes.sum
    r = (170 + (gen_colour % 55)).to_s(16)
    gen_colour = email.bytes.sum
    g = (170 + (gen_colour % 55)).to_s(16)
    gen_colour = login.bytes.sum
    b = (170 + (gen_colour % 55)).to_s(16)
    r, b, g = [r, b, g].map { |s| if s.size == 1 then '0' + s else s end }
    puts "#{name } #{r} #{name.bytes.sum} #{g} #{email.bytes.sum} #{b} #{login.bytes.sum}"
    return "##{r + b + g}"
  end

end
