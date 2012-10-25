class Absence < ActiveRecord::Base

  belongs_to :user

  validates_presence_of :start_time
  validates_presence_of :end_time

  # accessors used to produce start and end time
  attr_accessor :start_half_day
  attr_accessor :end_half_day

  validate :set_start_time
  validate :set_end_time

  def set_start_time
    if start_time and start_time.is_a?(DateTime)
      if start_half_day
        start_time.change(:hour => 13)
      else
        start_time.change(:hour => 9)
      end
    else
      errors.add :start_date, "can not be blank."
    end
  end

  def set_end_time
    if end_time and end_time.is_a?(DateTime)
      if end_half_day
        end_time.change(:hour => 13)
      else
        end_time.change(:hour => 17)
      end
    else
      errors.add :end_date, "can not be blank."
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
