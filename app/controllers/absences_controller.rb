class AbsencesController < ApplicationController

  before_filter :require_user
  before_filter :require_admin_user, :only => [:approve, :decline]

  before_filter :get_absence, :only => [:show, :edit, :update, :approve, :decline]

  def index
    if current_user.is_admin?
      @absences = Absence.all(:order => 'start_time ASC')
    else
      @absences = current_user.absences(:order => 'start_time ASC')
    end
  end

  def calendar
    @absences = Absence.all(:conditions => ['start_time > ? and end_time < ?',
                                            Time.now.beginning_of_month,
                                            Time.now.end_of_month])
  end

  def new
    if params[:start] and params[:end]
      @absence = Absence.new(:start_time => Time.parse(params[:start]),
                             :end_time => Time.parse(params[:end]))
    else
      @absence = Absence.new
    end
    @absence.user_id = current_user.id
  end

  def create
    @absence = Absence.new(params[:absence])
    if @absence.save
      flash[:notice] = "Your #{@absence.variety} has been requested. "
      flash[:notice] << 'Currently awaiting approval by your line manager.' if @absence.status == 'Pending'
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

  def approve
    if current_user == @absence.line_manager
      @absence.update_attribute :status, 'Approved'
      flash[:notice] = "You have approved #{@absence}."
    else
      flash[:error] = "You can not approve absences for #{@absence.user.name} as you are not their line manager.<br/>
Please contact #{@absence.user.line_manager.name}."
    end
    redirect_to absence_path(@absence)
  end

  def decline
    if current_user == @absence.line_manager
      @absence.update_attribute :status, 'Declined'
      flash[:notice] = "You have declined #{@absence}."
    else
      flash[:error] = "You can not decline absences for #{@absence.user.name} as you are not their line manager.<br/>
Please contact #{@absence.user.line_manager.name}."
    end
    redirect_to absence_path(@absence)
  end

def export
  @absences=Absence.all(:conditions => ['status = ?', 'Approved'])
  respond_to do |format|
    format.ics
  end
end

  def get_absence
    @absence = Absence.find(params[:id])
  end

end
