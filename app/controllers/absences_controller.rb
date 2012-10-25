class AbsencesController < ApplicationController

  before_filter :require_user
  before_filter :require_admin_user, :only => [:edit, :update]

  def index
    if current_user.is_admin?
      @absences = Absence.all # TODO limit to future, add parameters for archive
    else
      @absences = Absence.all(:conditions => ['user_id = ?', current_user.id])
    end
  end

  def new
    @absence = Absence.new
    @absence.user_id = current_user.id
  end

  def create
    @absence = Absence.new(params[:absence])
    @absence.status ||= 'Pending'
    if @absence.save
      flash[:notice] = "Your #{@absence.variety} has been requested."
      redirect_to absence_path(@absence)
    else
      render :new
    end
  end

end
