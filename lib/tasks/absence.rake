namespace :absence do

  # tasks for a chronjob to automatically notify users of upcoming absences
  desc "Notify employees and line managers of holidays in the next day"
  task :notify_next_day => :environment do
    Absence.all(:conditions => ["start_time > ? and start_time < ?", Time.now, Time.now + 24.hours]).each do |absence|
      m = UserMailer.notify_absence_upcoming(absence)
      puts m.inspect
    end
  end

  desc "Notify employees and line managers of holidays in the next week"
  task :notify_next_week => :environment do
    Absence.all(:conditions => ["start_time > ? and start_time < ?", Time.now, Time.now + 7.days]).each do |absence|
      m = UserMailer.notify_absence_upcoming(absence)
      puts m.inspect
    end
  end

end