class UserMailer < ActionMailer::Base

  add_template_helper(ApplicationHelper)

  def notify_new_user(user)
    @user = user
    mail(:to => user.email,
         :from => MAIL_CONFIG['username'],
         :subject => "You've been registered on HR-KISS")
  end

  def notify_approval_required(absence)
    @absence = absence
    @user = absence.user
    @manager = absence.user.line_manager
    mail(:to => @manager.email,
         :from => MAIL_CONFIG['username'],
         :subject => "Approval is needed for #{absence.to_s}")
  end

end
