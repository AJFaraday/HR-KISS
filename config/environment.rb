# Load the rails application
require File.expand_path('../application', __FILE__)
# Initialize the rails application
HRKISS::Application.initialize!

FactoryGirl.find_definitions

class NilClass
  def empty?
    true
  end
end


class Date
  def workday?
    self.wday != 6 and self.wday != 0 and ExemptDay.first(:conditions => ['day = ?', self]).nil?
  end
end
