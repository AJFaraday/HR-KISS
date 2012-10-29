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

    factory :admin do
      name 'mr admin'
      admin true
    end
  end


end