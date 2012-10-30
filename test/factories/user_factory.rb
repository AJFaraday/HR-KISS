require 'factory_girl'

FactoryGirl.define do

  factory :user do
    sequence(:login) { |n| "name#{n}"}
    name 'John Doe'
    password 'password'
    password_confirmation 'password'
    sequence(:email) { |n| "this#{n}@that.com" }
    line_manager_id { User.find_by_admin(true).id }
    admin false
    holiday_allowance 20
    sick_day_allowance 20
    holiday_remaining 20
    sick_days_remaining 20

    factory :admin do
      name 'mr admin'
      admin true
    end
  end


end