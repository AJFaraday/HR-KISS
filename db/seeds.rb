# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

# make_exempt_day('New Years Day', '1-1-2013')
def make_exempt_day(name,day)
  ExemptDay.create!(:name => name, :day => Date.parse(day))
  puts "Excempt Day #{name}, #{day} - CREATED"
rescue => er
  puts "Excempt Day #{name}, #{day} - CAN'T IMPORTED - #{er}"
end

if User.count == 0
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
end

# UK bank holidays until the end of 2013
make_exempt_day('Christmas Day',        '25-12-2012')
make_exempt_day('Boxing Day',           '26-12-2012')
make_exempt_day('New Years Day',        '1-1-2013')
make_exempt_day('Good Friday',          '29-3-2013')
make_exempt_day('Easter Monday',        '1-4-2013')
make_exempt_day('May Bank Holiday',     '6-5-2013')
make_exempt_day('Spring Bank Holiday',  '27-5-2013')
make_exempt_day('Summer Bank Holiday',  '26-8-2013')
make_exempt_day('Christmas Day',        '25-12-2013')
make_exempt_day('Boxing Day',           '26-12-2013')





