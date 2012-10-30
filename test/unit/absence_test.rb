require 'test_helper'

class AbsenceTest < ActiveSupport::TestCase

  def test_set_times_one_day
    @absence = Absence.create(:start_time => '1-10-2012 00:00',
                              :end_time => '4-10-2012 00:00',
                              :single_day => true,
                              :reason => 'reason',
                              :variety => 'Holiday',
                              :start_half_day => 'Full Day')
    assert @absence.valid?
    # end_time should be re-set to start day (for single day)
    assert_equal Date.parse('1-10-2012'), @absence.end_time.to_date
    # a full day, nine to 5
    assert_equal 9, @absence.start_time.hour
    assert_equal 17, @absence.end_time.hour
    assert_equal 1, @absence.days
    # morning 9 - 13
    @absence.update_attributes(:start_half_day => 'Morning')
    assert_equal 9, @absence.start_time.hour
    assert_equal 13, @absence.end_time.hour
    assert_equal 0.5, @absence.days
    # morning 13 - 17
    @absence.update_attributes(:start_half_day => 'Afternoon')
    assert_equal 13, @absence.start_time.hour
    assert_equal 17, @absence.end_time.hour
    assert_equal 0.5, @absence.days
  end

  def test_3_full_days
    @absence = Absence.create(:start_time => '1-10-2012 00:00',
                              :end_time => '3-10-2012 00:00',
                              :reason => 'reason',
                              :variety => 'Holiday',
                              :start_half_day => 'Full Day',
                              :end_half_day => 'Full Day')
    assert @absence.valid?
    # end_time should be re-set to start day (for single day)
    assert_equal Date.parse('3-10-2012'), @absence.end_time.to_date
    # a full day, nine to 5
    assert_equal 9, @absence.start_time.hour
    assert_equal 17, @absence.end_time.hour
    assert_equal 3, @absence.days
  end

  def test_start_half_day
    @absence = Absence.create(:start_time => '1-10-2012 00:00',
                              :end_time => '3-10-2012 00:00',
                              :reason => 'reason',
                              :variety => 'Holiday',
                              :start_half_day => 'Lunch Time',
                              :end_half_day => 'Full Day')
    assert @absence.valid?
    # end_time should be re-set to start day (for single day)
    assert_equal Date.parse('3-10-2012'), @absence.end_time.to_date
    # a full day, nine to 5
    assert_equal 13, @absence.start_time.hour
    assert_equal 17, @absence.end_time.hour
    assert_equal 2.5, @absence.days
  end

  def test_end_half_day
    @absence = Absence.create(:start_time => '1-10-2012 00:00',
                              :end_time => '3-10-2012 00:00',
                              :reason => 'reason',
                              :variety => 'Holiday',
                              :start_half_day => 'Full Day',
                              :end_half_day => 'Lunch Time')
    assert @absence.valid?
    # end_time should be re-set to start day (for single day)
    assert_equal Date.parse('3-10-2012'), @absence.end_time.to_date
    # a full day, nine to 5
    assert_equal 9, @absence.start_time.hour
    assert_equal 13, @absence.end_time.hour
    assert_equal 2.5, @absence.days
  end

  def test_start_and_end_half_day
    @absence = Absence.create(:start_time => '1-10-2012 00:00',
                              :end_time => '3-10-2012 00:00',
                              :reason => 'reason',
                              :variety => 'Holiday',
                              :start_half_day => 'Lunch Time',
                              :end_half_day => 'Lunch Time')
    assert @absence.valid?
    # end_time should be re-set to start day (for single day)
    assert_equal Date.parse('3-10-2012'), @absence.end_time.to_date
    # a full day, nine to 5
    assert_equal 13, @absence.start_time.hour
    assert_equal 13, @absence.end_time.hour
    assert_equal 2, @absence.days
  end

end
