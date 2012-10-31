class AbsencesController < ApplicationController

  before_filter :require_user
  # TODO check when an admin user is required (after acceptance?)
  #before_filter :require_admin_user

  before_filter :get_absence, :only => [:show, :edit, :update]

  def index
    if current_user.is_admin?
      @absences = Absence.all # TODO limit to future, add parameters for archive
    else
      @absences = current_user.absences
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

  def show
  end

  def edit
    @absence.set_single_day
  end

  def update
    if @absence.update_attributes(params[:absence])
      flash[:notice] = "Absence updated!"
      redirect_to absence_path(@absence)
    else
      render :action => :edit
    end
  end

  def get_absence
    @absence = Absence.find(params[:id])
  end

end
