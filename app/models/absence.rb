# Statuses ['Approved','Declined','Pending']
# varieties ['Holiday','Sick Days']
# Possible start ['Full Day','Morning','Afternoon']
# Possible end ['Full Day'.'lunch time']


class Absence < ActiveRecord::Base

  belongs_to :user

  # accessors used to produce start and end time
  attr_accessor :start_half_day
  attr_accessor :end_half_day
  attr_accessor :single_day

  validates_presence_of :reason
  validates_presence_of :variety

  validate :set_start_time
  validate :set_end_time
  validate :validate_start_is_before_end
  validate :no_sick_days_in_advance
  validate :approve_if_already_passed

  before_save :set_days

  # validations
  def set_start_time
    if self.start_time and self.start_time.is_a?(Time)
      single_day = start_time.to_date == end_time.to_date unless single_day and single_day == '1'
      if single_day and (single_day == '1' or single_day == true)
        self.end_time = self.start_time
        case start_half_day
          when "Full Day"
            self.start_time = self.start_time.change(:hour => 9)
          when 'Afternoon'
            self.start_time = self.start_time.change(:hour => 13)
          when 'Morning'
            self.start_time = self.start_time.change(:hour => 9)
        end
      else
        if start_half_day == 'Full Day'
          self.start_time = self.start_time.change(:hour => 9)
        else
          self.start_time = self.start_time.change(:hour => 13)
        end
      end
    else
      errors.add :start_time, "can not be blank."
    end
  end

  def set_end_time
    if self.end_time and self.end_time.is_a?(Time)
      single_day = (start_time.to_date == self.end_time.to_date) unless single_day and single_day == '1'
      if single_day and (single_day == '1' or single_day == true)
        case start_half_day
          when "Full Day"
            self.end_time = self.end_time.change(:hour => 17)
          when 'Afternoon'
            self.end_time = self.end_time.change(:hour => 17)
          when 'Morning'
            self.end_time = self.end_time.change(:hour => 13)
        end
      else
        if end_half_day == 'Full Day'
          self.end_time = self.end_time.change(:hour => 17)
        else
          self.end_time = self.end_time.change(:hour => 13)
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

  def approve_if_already_passed
    if end_time < Date.tomorrow.beginning_of_day
      status ||= 'Approved'
    end
  end

  def validate_start_is_before_end
    if start_time > end_time
      errors.add :base, "You can not start your absence after you end your absence."
    end
  end

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

  # presentation methods
  def to_s
    "#{user.name} - #{variety} - #{start_time.strftime('%d-%m-%Y')} to #{end_time.strftime('%d-%m-%Y')}"
  end

  def show_time
    "#{start_time.strftime('%d-%m-%Y')} to #{end_time.strftime('%d-%m-%Y')}"
  end

  def get_days
    if self.valid?
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
        count += 1 if day.workday?
      end
      return count
    else
      logger.info 'Invalid absence, not working out days.'
      return nil
    end
  end

  def set_days
    self.days = get_days
  end

end


