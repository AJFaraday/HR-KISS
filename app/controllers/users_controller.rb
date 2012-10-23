class UsersController < ApplicationController

  before_filter :require_user, :only => [:show, :edit, :update, :delete]
  before_filter :require_admin_user, :only => [:new, :create, :index]
  before_filter :get_user, :except => [:index, :new, :edit]

  def index

  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Your account has been created."
      redirect_to signup_url
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
      redirect_to account_url
    else
      render :action => :edit
    end
  end

  private

  def get_user
    if current_user.is_admin?
      @user = User.find(params[:user])
    else
      @user = current_user
    end
  end

end


