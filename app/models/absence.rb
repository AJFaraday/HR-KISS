# Statuses ['Approved','Declined','Pending']
# varieties ['Holiday','Sick Days']

class Absence < ActiveRecord::Base

  belongs_to :user

  # accessors used to produce start and end time
  attr_accessor :start_half_day
  attr_accessor :end_half_day

  validates_presence_of :reason
  validates_presence_of :variety

  validate :set_start_time
  validate :set_end_time
  validate :no_sick_days_in_advance
  validate :approve_if_already_passed

  # validations
  def set_start_time
    if start_time and start_time.is_a?(Time)
      if start_half_day == '1'
        start_time.change(:hour => 13)
      else
        start_time.change(:hour => 9)
      end
    else
      errors.add :start_time, "can not be blank."
    end
  end

  def set_end_time
    if end_time and end_time.is_a?(Time)
      if end_half_day = '1'
        end_time.change(:hour => 13)
      else
        end_time.change(:hour => 17)
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
