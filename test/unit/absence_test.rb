require 'test_helper'

class AbsenceTest < ActiveSupport::TestCase

  def setup
    #@absence = FactoryGirl.new(:absence)
  end

  def test_set_times_one_day
    puts Rails.env
    @absence = Absence.create(:start_time => '1-10-2012',
                              :end_time => '4-10-2012',
                              :single_day => true,
                              :reason => 'reason',
                              :variety => 'Holiday',
                              :start_half_day => 'Full Day')
    # end_time should be re-set to start day (for single day)
    assert_equal Date.parse('1-10-2012'), @absence.end_time.to_date
    # a full day, nine to 5
    @absence.valid?
    assert_equal 9, @absence.start_time.hour
    assert_equal 17, @absence.end_time.hour

  end

end
