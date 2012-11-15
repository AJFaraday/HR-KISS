class UsersController < ApplicationController

  before_filter :require_user, :only => [:show, :edit, :update, :delete]
  before_filter :require_admin_user, :only => [:new, :create, :index, :delete]
  before_filter :get_user, :except => [:index, :new, :create]

  def index
    params[:page] ? @page = params[:page] : @page = 0
    @users = User.all(:limit => 20,
                      :order => 'login ASC',
                      :offset => (@page * 20))
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Your account has been created."
      redirect_to root_path
    else
      flash[:notice] = "There was a problem creating you."
      render :action => :new
    end

  end

  def show
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to user_path(@user)
    else
      render :action => :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:notice] = "You've deleted this user from your records, they are no more (in the HR database)."
    else
      flash[:error] = "Something went wrong! This user can not be deleted... #{@user.errors.full_messages.join('<br/>')}"
    end
    render users_path
  rescue => er
    flash[:error] = "Something went wrong! This user can not be deleted... #{er.message}"
    render users_path
  end

  private

  def get_user
    if current_user.is_admin?
      @user = User.find(params[:id])
    else
      @user = current_user
    end
  end

end


