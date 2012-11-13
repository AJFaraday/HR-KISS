class UserMailer < ActionMailer::Base

  def notify_new_user(user)
    @user = user
    mail(:to => user.email,
         :from => 'marmitejunction@gmail.com',
         :subject => "You've been registered on HR-KISS")
  end

end
