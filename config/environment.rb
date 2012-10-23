# Load the rails application
require File.expand_path('../application', __FILE__)

#require File.expand_path('../app/form_builders')

# Initialize the rails application
HRKISS::Application.initialize!


class NilClass
  def empty?
    true
  end
end
