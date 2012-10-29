# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

admin_user = User.create({:login => 'admin',
                          :password => 'admin', 
                          :password_confirmation => 'admin', 
                          :email => 'admin@ad.min',
                          :admin => true})
admin_user.save(:validate => false)
