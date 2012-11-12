require 'test_helper'

class ExemptDayTest < ActiveSupport::TestCase

  def test_exepmt_day_missed_in_absence_count
    day = ExemptDay.create(:day => Date.parse('1-1-2013'),
                     :name => 'new years day')
    assert_valid day

    absence = Absence.create(:start_time => '31-12-2012 00:00',
                             :end_time => '2-1-2013 00:00',
                             :reason => 'reason',
                             :user_id => User.find_by_admin(true).id,
                             :variety => 'Holiday',
                             :start_half_day => 'Full Day',
                             :end_half_day => 'Lunch Time')
    assert_valid absence
    assert_equal 13, absence.end_time.hour
    assert_equal 1.5, absence.days
  end

  def test_update_absences
    absence = Absence.create(:start_time => '31-12-2012 00:00',
                             :end_time => '2-1-2013 00:00',
                             :reason => 'reason',
                             :user_id => User.find_by_admin(true).id,
                             :variety => 'Holiday',
                             :start_half_day => 'Full Day',
                             :end_half_day => 'Lunch Time')
    assert_valid absence
    assert_equal 2.5, absence.days

    day = ExemptDay.create(:day => Date.parse('1-1-2013'),
                     :name => 'new years day')
    assert_valid day
    assert_equal 1, day.absences_on_day.count

    absence.reload
    assert_equal 1.5, absence.days
  end

  def test_update_absences_single_day
    absence = Absence.create(:start_time => '1-1-2013 00:00',
                             :end_time => '1-1-2013 00:00',
                             :reason => 'reason',
                             :single_day => true,
                             :user_id => User.find_by_admin(true).id,
                             :variety => 'Holiday',
                             :start_half_day => 'Full Day')
    assert_valid absence
    assert_equal 1, absence.days

    day = ExemptDay.create(:day => Date.parse('1-1-2013'),
                     :name => 'new years day')
    assert_valid day
    assert_equal 1, day.absences_on_day.count

    absence.reload
    assert_equal 0, absence.days
  end

end
