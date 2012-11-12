class ExemptDay < ActiveRecord::Base

  validates_presence_of :day
  validates_presence_of :name
  validates_uniqueness_of :day

  default_scope :order => 'day ASC'

  after_save :update_absences

  after_destroy :update_all_absences

  def to_s
    "Exempt day - #{name} - #{day.strftime('%d-%m-%Y')}"
  end

  def absences_on_day
    Absence.on_day(day)
  end

  def update_absences
    absences_on_day.each do |absence|
      absence.set_days
      absence.save!
    end
  end

  def update_all_absences
    Absence.all.each do |absence|
      absence.set_days
      absence.save!
    end
  end

end
