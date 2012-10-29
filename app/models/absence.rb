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

  attr_accessor :single_morning

  validates_presence_of :reason
  validates_presence_of :variety

  validate :set_start_time
  validate :set_end_time
  validate :validate_start_is_before_end
  validate :no_sick_days_in_advance
  validate :approve_if_already_passed

  # validations
  def set_start_time
    if start_time and start_time.is_a?(Time)
      if single_day and single_day == '1'
        case start_half_day
          when "Full Day"
            start_time.change(:hour => 9)            
          when 'Afternoon'
            start_time.change(:hour => 13)            
          when 'Morning'
            start_time.change(:hour => 9)            
        end
      else
        if start_half_day == 'Full Day'
          start_time.change(:hour => 9)
        else
          start_time.change(:hour => 13)
        end
      end
    else
      errors.add :start_time, "can not be blank."
    end
  end

  def set_end_time
    if end_time and end_time.is_a?(Time)
      if single_day and single_day == '1'
        case start_half_day
          when "Full Day"
            end_time.change(:hour => 17)            
          when 'Afternoon'
            end_time.change(:hour => 17)            
          when 'Morning'
            end_time.change(:hour => 13)            
        end
      else
        if end_half_day == 'Full Day'
          end_time.change(:hour => 17)
        else
          end_time.change(:hour => 13)
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

end
