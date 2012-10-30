require 'test_helper'

class AbsenceTest < ActiveSupport::TestCase

  def test_set_times_one_day
    @absence = Absence.create(:start_time => '1-10-2012 00:00',
                              :end_time => '4-10-2012 00:00',
                              :single_day => true,
                              :reason => 'reason',
                              :user_id => User.find_by_admin(true).id,
                              :variety => 'Holiday',
                              :start_half_day => 'Full Day')
    assert_valid @absence
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
                              :user_id => User.find_by_admin(true).id,
                              :variety => 'Holiday',
                              :start_half_day => 'Full Day',
                              :end_half_day => 'Full Day')
    assert_valid @absence
    assert_equal Date.parse('3-10-2012'), @absence.end_time.to_date
    assert_equal 9, @absence.start_time.hour
    assert_equal 17, @absence.end_time.hour
    assert_equal 3, @absence.days
  end

  def test_start_half_day
    @absence = Absence.create(:start_time => '1-10-2012 00:00',
                              :end_time => '3-10-2012 00:00',
                              :reason => 'reason',
                              :user_id => User.find_by_admin(true).id,
                              :variety => 'Holiday',
                              :start_half_day => 'Lunch Time',
                              :end_half_day => 'Full Day')
    assert_valid @absence
    assert_equal Date.parse('3-10-2012'), @absence.end_time.to_date
    assert_equal 13, @absence.start_time.hour
    assert_equal 17, @absence.end_time.hour
    assert_equal 2.5, @absence.days
  end

  def test_end_half_day
    @absence = Absence.create(:start_time => '1-10-2012 00:00',
                              :end_time => '3-10-2012 00:00',
                              :reason => 'reason',
                              :user_id => User.find_by_admin(true).id,
                              :variety => 'Holiday',
                              :start_half_day => 'Full Day',
                              :end_half_day => 'Lunch Time')
    assert_valid @absence
    assert_equal Date.parse('3-10-2012'), @absence.end_time.to_date
    assert_equal 9, @absence.start_time.hour
    assert_equal 13, @absence.end_time.hour
    assert_equal 2.5, @absence.days
  end

  def test_start_and_end_half_day
    @absence = Absence.create(:start_time => '1-10-2012 00:00',
                              :end_time => '3-10-2012 00:00',
                              :reason => 'reason',
                              :user_id => User.find_by_admin(true).id,
                              :variety => 'Holiday',
                              :start_half_day => 'Lunch Time',
                              :end_half_day => 'Lunch Time')
    assert_valid @absence
    assert_equal Date.parse('3-10-2012'), @absence.end_time.to_date
    assert_equal 13, @absence.start_time.hour
    assert_equal 13, @absence.end_time.hour
    assert_equal 2, @absence.days
  end

  # recording past absences doesn't require approval
  def test_set_status
    # in the future
    @absence = Absence.create(:start_time => '1-10-3000 00:00',
                              :end_time => '1-10-3000 00:00',
                              :reason => 'reason',
                              :user_id => User.find_by_admin(true).id,
                              :variety => 'Holiday',
                              :start_half_day => 'Lunch Time',
                              :end_half_day => 'Lunch Time')
    assert_valid @absence
    assert_equal 'Pending', @absence.status
    # in the past
    @absence = Absence.create(:start_time => '1-10-1000 00:00',
                              :end_time => '1-10-1000 00:00',
                              :reason => 'reason',
                              :user_id => User.find_by_admin(true).id,
                              :variety => 'Holiday',
                              :start_half_day => 'Lunch Time',
                              :end_half_day => 'Lunch Time' )
    assert_valid @absence
    assert_equal 'Approved', @absence.status
  end

  # INVALID tests

  def test_sick_days_in_advance
    @absence = Absence.create(:start_time => '1-10-2222 00:00',
                              :end_time => '3-10-2222 00:00',
                              :reason => 'reason',
                              :user_id => User.find_by_admin(true).id,
                              :variety => 'Sick Days')
    assert_not_valid @absence
    assert @absence.errors[:base]
    assert @absence.errors[:base].include?("You can not book sick days in advance.")
  end

  def test_crossed_start_and_end
    @absence = Absence.create(:start_time => '3-10-2222 00:00',
                              :end_time => '1-10-2222 00:00',
                              :reason => 'reason',
                              :user_id => User.find_by_admin(true).id,
                              :variety => 'Sick Days',
                              :start_half_day => 'Lunch Time',
                              :end_half_day => 'Lunch Time')
    assert_not_valid @absence
    assert @absence.errors[:base]
    assert @absence.errors[:base].include?("You can not start your absence after you end your absence.")
  end

end
