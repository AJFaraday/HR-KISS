class Admin::UsersController < ApplicationController

  before_filter :require_admin_user

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

end
