class ExemptDaysController < ApplicationController

  def index
    @exempt_days = ExemptDay.all
  end

  def new
    @exempt_day = ExemptDay.new
  end

  def edit
    @exempt_day = ExemptDay.find(params[:id])
  end

  def create
    @exempt_day = ExemptDay.new(params[:exempt_day])
    if @exempt_day.save
      flash[:notice] = 'Exempt day was successfully created.'
      redirect_to exempt_days_path
    else
      render :action => "new"
    end
  end

  def update
    @exempt_day = ExemptDay.find(params[:id])
    if @exempt_day.update_attributes(params[:exempt_day])
      flash[:notice] = 'Exempt day was successfully updated.'
      redirect_to exempt_days_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @exempt_day = ExemptDay.find(params[:id])
    @exempt_day.destroy
    flash[:notice] = "You've cancelled '#{@exempt_day.name}'"
    redirect_to exempt_days_path
  end

end
