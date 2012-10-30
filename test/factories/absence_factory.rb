require 'factory_girl'

FactoryGirl.define do

  factory :absence do
    start_time {Date.parse '3-2-2020'}
    end_time {Date.parse '5-2-2020'}
    reason {'holiday'}
    variety 'Holiday'
    association :user

    factory :past_holiday do
      start_time {Date.parse '1-10-2012'}
      end_time {Date.parse '5-10-2012'}
      status 'Approved'
    end

    factory :long_past_holiday do
      start_time {Date.parse '1-10-2010'}
      end_time {Date.parse '5-10-2010'}
      status 'Approved'
    end

    factory :sick_day do
      variety 'Sick Days'
    end

    factory :past_sick_day do
      start_time {Date.parse '1-10-2012'}
      end_time {Date.parse '5-10-2012'}
      variety 'Sick Days'
      status 'Approved'
    end

    factory :one_morning do
      start_time {Time.parse '1-10-2012 9:00'}
      end_time {Time.parse '1-10-2012 13:00'}
      status 'Approved'
    end

    factory :one_afternoon do
      start_time {Time.parse '1-10-2012 13:00'}
      end_time {Time.parse '1-10-2012 17:00'}
      status 'Approved'
    end

  end

end