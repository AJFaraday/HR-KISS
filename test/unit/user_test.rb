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
  
  
end
