class ExemptDay < ActiveRecord::Base

  validates_presence_of :day
  validates_presence_of :name

  default_scope :order => 'day ASC'

  def to_s
    "Exempt day - #{name} - #{day.strftime('%d-%m-%Y')}"
  end

end
