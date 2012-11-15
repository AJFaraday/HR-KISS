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

  def notify_absence_declined(absence)
    @absence = absence
    @user = absence.user
    mail(:to => @user.email,
         :from => MAIL_CONFIG['username'],
         :subject => "#{@user.line_manager.name} has declined your request for absence.")
  end

  def notify_absence_approved(absence)
    @absence = absence
    @user = absence.user
    mail(:to => @user.email,
         :from => MAIL_CONFIG['username'],
         :subject => "#{@user.line_manager.name} has approved your request for absence.")
  end

  def notify_absence_upcoming(absence)
    @absence = absence
    @user = absence.user
    mail(:to => @user.email,
         :from => MAIL_CONFIG['username'],
         :subject => "Your absence is upcoming - #{absence.to_s}").deliver
    mail(:to => @user.line_manager.email,
         :from => MAIL_CONFIG['username'],
         :subject => "Employee absence is upcoming - #{absence.to_s}").deliver
  end

end
