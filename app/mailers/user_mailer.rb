class UserMailer < ActionMailer::Base

  def notify_new_user(user)
    @user = user
    mail(:to => user.email,
         :from => MAIL_CONFIG['username'],
         :subject => "You've been registered on HR-KISS")
  end

end
