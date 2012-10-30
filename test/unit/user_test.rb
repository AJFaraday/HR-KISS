require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = FactoryGirl.create(:user)
    assert_valid @user
  end

  def test_holidays_this_year
    assert_equal 0, @user.absences.count
    assert_equal 0, @user.absences.holidays_this_year.count

    FactoryGirl.create(:absence,
                       :start_time => Time.now - 1.year,
                       :end_time => Time.now - 11.months,
                       :user => @user)
    FactoryGirl.create(:absence,
                       :start_time => Time.now + 13.months,
                       :end_time => Time.now + 14.months,
                       :user => @user)
    assert_equal 2, @user.absences.count
    assert_equal 0, @user.absences.holidays_this_year.count

    absence = FactoryGirl.create(:absence,
                                 :start_time => Time.now,
                                 :end_time => Time.now + 1.days,
                                 :user => @user)
    assert_equal 3, @user.absences.count
    assert_equal 0, @user.absences.holidays_this_year('Approved').count
    assert_equal 1, @user.absences.holidays_this_year('Pending').count
    assert_equal 1, @user.absences.holidays_this_year.count

    absence = FactoryGirl.create(:absence,
                                 :start_time => Time.now,
                                 :end_time => Time.now + 1.days,
                                 :user => @user,
                                 :status => 'Approved')
    assert_equal 4, @user.absences.count
    assert_equal 1, @user.absences.holidays_this_year('Approved').count
    assert_equal 2, @user.absences.holidays_this_year.count
  end

  def test_sick_days_this_year
    assert_equal 0, @user.absences.count
    assert_equal 0, @user.absences.sick_days_this_year.count

    FactoryGirl.create(:sick_day,
                       :start_time => Time.now - 1.year,
                       :end_time => Time.now - 11.months,
                       :user => @user)
    assert_equal 1, @user.absences.count
    assert_equal 0, @user.absences.sick_days_this_year.count

    absence = FactoryGirl.create(:sick_day,
                                 :start_time => Time.now,
                                 :end_time => Time.now + 1.days,
                                 :user => @user)
    assert_equal 2, @user.absences.count
    assert_equal 1, @user.absences.sick_days_this_year.count
    assert_equal 0, @user.absences.sick_days_this_year('Approved').count
    assert_equal 1, @user.absences.sick_days_this_year('Pending').count

    absence = FactoryGirl.create(:sick_day,
                                 :start_time => Time.now - 2.days,
                                 :end_time => Time.now - 1.days,
                                 :user => @user)
    assert_equal 3, @user.absences.count
    assert_equal 1, @user.absences.sick_days_this_year('Approved').count
    assert_equal 2, @user.absences.sick_days_this_year.count
  end

  def test_set_days_holiday
    assert_equal 20, @user.holiday_allowance
    assert_equal 20, @user.holiday_remaining

    absence = FactoryGirl.create(:absence,
                                 :start_time => Time.now + 1.year,
                                 :end_time => Time.now + 1.year + 1.days,
                                 :user => @user)
    assert_equal 20, @user.holiday_remaining

    # Date.commercial will find next monday
    absence = FactoryGirl.create(:absence,
                                 :start_time => Date.commercial(Date.today.year, 1+Date.today.cweek, 1),
                                 :end_time => Date.commercial(Date.today.year, 1+Date.today.cweek, 1),
                                 :user => @user,
                                 :status => "Approved")
    @user.set_days
    assert_equal 19, @user.holiday_remaining

    absence = FactoryGirl.create(:absence,
                                 :start_time => Date.commercial(Date.today.year, 2+Date.today.cweek, 1),
                                 :end_time => Date.commercial(Date.today.year, 2+Date.today.cweek, 1) + 3.days,
                                 :end_half_day => 'Lunch Time',
                                 :user => @user,
                                 :status => "Approved")
    @user.set_days
    assert_equal 15.5, @user.holiday_remaining
  end

  def test_set_days_sick_days
    assert_equal 20, @user.sick_day_allowance
    assert_equal 20, @user.sick_days_remaining

    absence = FactoryGirl.create(:sick_day,
                                 :start_time => Time.now - 1.year,
                                 :end_time => Time.now - 1.year + 1.days,
                                 :user => @user)
    assert_equal 20, @user.sick_days_remaining

    # Date.commercial will find next monday
    absence = FactoryGirl.create(:sick_day,
                                 :start_time => Date.commercial(Date.today.year, 1-Date.today.cweek, 1),
                                 :end_time => Date.commercial(Date.today.year, 1-Date.today.cweek, 1),
                                 :user => @user,
                                 :status => "Approved")
    @user.set_days
    assert_equal 19, @user.sick_days_remaining

    absence = FactoryGirl.create(:sick_day,
                                 :start_time => Date.commercial(Date.today.year, 2-Date.today.cweek, 1),
                                 :end_time => Date.commercial(Date.today.year, 2-Date.today.cweek, 1) + 3.days,
                                 :end_half_day => 'Lunch Time',
                                 :user => @user,
                                 :status => "Approved")
    @user.set_days
    assert_equal 15.5, @user.sick_days_remaining
  end

  def test_present_and_absent
    assert @user.present?
    assert !@user.absent?
    FactoryGirl.create(:absence,
                       :start_time => Date.today - 1.day,
                       :end_time => Date.today + 1.day,
                       :user => @user)

    assert !@user.present?
    assert @user.absent?
  end



end
