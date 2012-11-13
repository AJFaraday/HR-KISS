MAIL_CONFIG = YAML.load_file("#{Rails.root}/config/mail.yml")['mail']

ActionMailer::Base.delivery_method = :smtp

# Currently only possible with gmail
ActionMailer::Base.smtp_settings = {
  :tls => true,
  :address => 'smtp.gmail.com',
  :port => "587",
  :domain => 'gmail.com',
  :authentication => 'plain',
  :user_name => MAIL_CONFIG['username'],
  :password => MAIL_CONFIG['password']
 }

