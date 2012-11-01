class Flex < ActiveRecord::Base

  belongs_to :user

  default_scope :order => 'position ASC'

  validates_presence_of :user
  validates_presence_of :comment
  validate :hours_and_or_minutes

  after_initialize :set_initial_columns
  before_save :minutes_to_hours
  before_save :set_totals
  after_save :cascade_totals_if_discarded

  def set_initial_columns
    if self.new_record?
      if user and user.flexes.any?
        self.position = user.flexes.last.position + 1
      else
        self.position = 1
      end
      self.hours ||= 0
      self.minutes ||= 0
      self.positive = true if self.positive.nil?
      self.discarded = false if self.discarded.nil?
    end
  end

  def hours_and_or_minutes
    if hours.in?([nil,0,'0']) and minutes.in?([nil,0,'0'])
      errors.add :base, 'Hours or minutes must be more than zero. (Flexing your time by nothing is leaving it be)'
    end
  end

  def minutes_to_hours
    if self.minutes >= 60
      self.hours = self.hours += self.minutes/60
      self.minutes = self.minutes % 60
    end
  end

  def total_minutes_to_hours
    if self.total_minutes >= 60
      self.total_hours = self.total_hours += self.total_minutes/60
      self.total_minutes = self.total_minutes % 60
    end
    # clears some odditites while using mod and negative numbers
    if self.total_minutes <= -60
      self.total_hours = self.total_hours * -1
      self.total_minutes = self.total_minutes * -1

      self.total_hours = self.total_hours += self.total_minutes/60
      self.total_minutes = self.total_minutes % 60

      self.total_hours = self.total_hours * -1
      self.total_minutes = self.total_minutes * -1
    end
  end

  def set_totals
    minutes_to_hours
    if positive.in?([0,'0',false])
      self.minutes = self.minutes.abs*-1
      self.hours = self.hours.abs*-1
    end
    if last_position
      self.total_hours = self.hours + last_position.total_hours
      self.total_minutes = self.minutes + last_position.total_minutes
    else
      self.total_hours = self.hours
      self.total_minutes = self.minutes
    end
    self.total_minutes_to_hours
  end

  # When a flex is discarded (crossed out), all the later totals have to change
  def cascade_totals_if_discarded
    if self.discarded.in?([true,1,'1'])
      later_flexes = user.flexes.all(:conditions => ['position > ?', self.position],
                                     :order => 'position ASC')
      later_flexes.each do |flex|
        flex.save!
      end
    end
  end

  def last_position
    pos = self.position - 1
    previous = nil
    until previous or pos <= 0
      previous = user.flexes.find_by_position_and_discarded pos, false
      pos -= 1
    end
    previous
  end
  
  def to_s
    "#{user.name} - #{position} - #{hours}:#{minutes} - #{total_hours}:#{total_minutes}"
  end
  
end
