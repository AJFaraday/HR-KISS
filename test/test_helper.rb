ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  def assert_valid(object, message=nil)
    puts object.errors.full_messages.join("\r\n") unless object.valid?
    assert_block(build_message(message, "<?> is not valid.", object.class.to_s)) {object.valid?}
  end

  def assert_not_valid(object, message=nil)
    puts object.errors.full_messages.join("\r\n") unless object.valid?
    assert_block(build_message(message, "<?> should not be valid.", object.class.to_s)) {!object.valid?}
  end

end
