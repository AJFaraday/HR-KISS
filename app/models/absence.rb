# Statuses ['Approved','Declined','Pending']
# varieties ['Holiday','Sick Days']
# Possible start ['Full Day','Morning','Afternoon']
# Possible end ['Full Day'.'lunch time']


class Absence < ActiveRecord::Base

  include Rails.application.routes.url_helpers

  belongs_to :user

  delegate :line_manager, :to => :user

  # accessors used to produce start and end time
  attr_accessor :start_half_day
  attr_accessor :end_half_day
  attr_accessor :single_day

  validates_presence_of :reason
  validates_presence_of :variety
  validates_presence_of :user

  validate :set_start_time
  validate :set_end_time
  validate :validate_start_is_before_end
  validate :no_sick_days_in_advance
  validate :set_status
  validate :avoid_overlapping

  before_save :set_days
  after_save :set_user_days

  after_initialize :single_day_from_dates

  after_save :notify_user

  def notify_user
    if status == 'Pending'
      UserMailer.notify_approval_required(self).deliver
    end
  end

  def single_day_from_dates
    if start_time and end_time
      if start_time.to_date == end_time.to_date
        self.single_day = true
      end
    end
  end

  # validations

  def avoid_overlapping
    if start_time and end_time
      if user.absences.first(:conditions => ['start_time > ? and start_time < ? and id != ?',
                                             self.start_time, self.end_time, (self.id ? self.id : 0)]) or
          user.absences.first(:conditions => ['end_time > ? and end_time < ? and id != ?',
                                              self.start_time, self.end_time, (self.id ? self.id : 0)])
        errors.add :base, "You can not book overlapping absences."
      end
    end
  end

  def set_start_time
    if self.start_time and self.start_time.is_a?(Time)
      set_single_day
      if self.single_day and self.single_day.in?([true, '1'])
          case start_half_day
            when "Full Day"
              self.start_time = self.start_time.change(:hour => 9)
            when 'Afternoon'
              self.start_time = self.start_time.change(:hour => 13)
            when 'Morning'
              self.start_time = self.start_time.change(:hour => 9)
          end
      else
        if self.start_half_day.empty?
          (self.start_time.hour == 13) ? self.start_half_day = 'Lunch Time' : self.start_half_day = 'Full Day'
        end
        if start_half_day == 'Lunch Time'
          self.start_time = self.start_time.change(:hour => 13)
        else
          self.start_time = self.start_time.change(:hour => 9)
        end
      end
    else
      errors.add :start_time, "can not be blank."
    end
  end

  def set_end_time
    if (self.end_time and self.end_time.is_a?(Time)) or ['1', true].any? { |x| single_day == x }
      set_single_day
      if self.single_day and (self.single_day == '1' or self.single_day == true)
          self.end_time = self.start_time
          case start_half_day
            when "Full Day"
              self.end_time = self.end_time.change(:hour => 17)
            when 'Afternoon'
              self.end_time = self.end_time.change(:hour => 17)
            when 'Morning'
              self.end_time = self.end_time.change(:hour => 13)
          end
      else
        if self.end_half_day.empty?
          (self.end_time.hour == 13) ? self.end_half_day = 'Lunch Time' : self.end_half_day = 'Full Day'
        end
        if end_half_day == 'Lunch Time'
          self.end_time = self.end_time.change(:hour => 13)
        else
          self.end_time = self.end_time.change(:hour => 17)
        end
      end
    else
      errors.add :end_time, "can not be blank."
    end
  end

  def no_sick_days_in_advance
    if variety == "Sick Days"
      if start_time > Date.tomorrow.beginning_of_day
        errors.add :base, "You can not book sick days in advance." and return
      end
    end
  end

  def set_status
    if start_time and end_time
      if end_time < Date.today.beginning_of_day + 1.minute
        self.status ||= 'Approved'
      else
        self.status ||= 'Pending'
      end
    end
  end

  def validate_start_is_before_end
    if start_time and end_time
      if start_time > end_time
        errors.add :base, "You can not start your absence after you end your absence."
      end
    end
  end


  def to_jquery_attributes
    {:title => "'#{calendar_title}'",
     :start => "'#{start_time.rfc822}'",
     :end => "'#{end_time.rfc822}'",
     :url => "'#{absence_path(self)}'"}
  end

  def self.all_to_jquery
    all.collect { |absence| absence.to_jquery_attributes }.to_json.gsub('"', '')
  end

  # named_scope equivalents (seems standard for rails 3)

  def self.current(status = nil)
    if status
      all(:conditions => ['start_time < ? and end_time > ? and status = ?',
                          Time.now, Time.now, status], :order => "start_time ASC")
    else
      all(:conditions => ['start_time < ? and end_time > ?', Time.now, Time.now], :order => "start_time ASC")
    end

  end

  def self.past(status=nil)
    if status
      all(:conditions => ['end_time < ? and status = ?', Time.now, status], :order => "start_time ASC")
    else
      all(:conditions => ['end_time < ?', Time.now], :order => "start_time ASC")
    end
  end

  def self.future(status=nil)
    if status
      all(:conditions => ['start_time > ? and status = ?', Time.now, status], :order => "start_time ASC")
    else
      all(:conditions => ['start_time > ?', Time.now], :order => "start_time ASC")
    end
  end


  # presentation methods
  def to_s
    "#{user.name} - #{variety} - #{start_time.strftime('%d-%m-%Y')} to #{end_time.strftime('%d-%m-%Y')} - #{status}"
  end

  def calendar_title
    "#{user.name} - #{variety} - #{reason} - (#{status})"
  end

  def show_times(line_breaks = false)
    if line_breaks
      display = "#{self.start_time.strftime('%d-%m-%Y %I:%M%p')}<br/>to<br/>#{self.end_time.strftime('%d-%m-%Y %I:%M%p')}"
    else
      display = "#{self.start_time.strftime('%d-%m-%Y %I:%M%p')} to #{self.end_time.strftime('%d-%m-%Y %I:%M%p')}"
    end
    return ActiveSupport::SafeBuffer.new(display)
  end

  def get_days
    set_single_day
    count = 0
    if self.valid?
      if single_day
        if 13.in?([start_time.hour, end_time.hour])
          count = 0.5 if start_time.to_date.workday?
        else
          count = 1 if start_time.to_date.workday?
        end
      else
        day = start_time.to_date
        count = 0.0
        if start_time.hour == 13
          count += 0.5 if day.workday?
          day += 1.day
        end
        until day >= end_time.to_date do
          count += 1.0 if day.workday?
          day = day + 1.day
        end
        if end_time.hour == 13
          count += 0.5 if day.workday?
        else
          count += 1 if day.workday? and day != start_time.to_date
        end
      end
      return count
    else
      puts 'Invalid absence, not working out days.'
      return nil
    end
  end

  def set_days
    self.days = get_days
  end

  def set_user_days
    user.set_days(true)
  end

  def set_single_day
    self.single_day = (start_time.to_date == self.end_time.to_date) unless self.single_day and self.single_day.in?([true, '1'])
  end

  def decline_confirm_message
    "Are you sure you want to decline this holiday request?"
  end

  def approve_confirm_message
    if end_time.year == Date.today.year and start_time.year == Date.today.year
      remaining = self.user.holiday_remaining - self.days
      if remaining >= 0
        "This #{days} day holiday will leave #{user.name} with #{remaining} days of holiday this year.\r\n
Are you sure you want to approve this holiday?"
      else
        "This #{days} day holiday will leave #{user.name} #{remaining * -1} days OVER their holiday allowance.\r\n
Are you sure you want to approve this holiday?"
      end
    else
      "This holiday will take #{days} days from #{user.name} in #{start_time.year}.\r\n
Are you sure you want to approve this holiday?"
    end
  end

  def ical
    e=Icalendar::Event.new
    e.uid="HRKISS-#{created_at.to_i}-#{self.id}"
    e.dtstart=DateTime.civil(self.start_time.year, self.start_time.month, self.start_time.day, self.start_time.hour, self.start_time.min)
    e.dtend=DateTime.civil(self.end_time.year, self.end_time.month, self.end_time.day, self.end_time.hour, self.end_time.min)
    e.summary=self.to_s
    e
  end


  def self.on_day(day)
    result = Absence.all(:conditions => ['start_time < ? and end_time > ?', day.end_of_day, day.beginning_of_day])
    return result.uniq
  end

  def approve
    update_attribute :status, 'Approved'
    UserMailer.notify_absence_approved(self).deliver
  end

  def decline
    update_attribute :status, 'Declined'
    UserMailer.notify_absence_declined(self).deliver
  end

end



