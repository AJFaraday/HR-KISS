# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

admin_user = User.new({:login => 'admin',
                       :name => 'Brian the Admin',
                       :password => 'admin',
                       :password_confirmation => 'admin',
                       :email => 'admin@ad.min',
                       :holiday_allowance => 20,
                       :sick_day_allowance => 20,
                       :admin => true})
admin_user.save(:validate => false)
admin_user.line_manager_id = admin_user.id
puts admin_user.inspect
