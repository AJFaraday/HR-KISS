class FlexesController < ApplicationController

  before_filter :get_flex, :only => [:discard, :restore]
  before_filter :require_user

  def index
    if current_user.is_admin? and params[:user_id]
      @user = User.find params[:user_id]
    else
      @user = current_user
    end
    @flex = @user.flexes.new
    @flexes = @user.flexes.for_timeline
  end

  def create
    @flex = Flex.new(params[:flex])
    @user = @flex.user
    if @flex.save
      if @user == current_user
        flash[:notice] = "You've logged this flex on your timeline."
      else
        flash[:notice] = "You've logged this flex for #{@user.name}"
      end
      @flex = Flex.new(:user_id => @user.id)
    else
      flash[:error] = "Something's wrong, this flex could not be logged."
    end
    if params[:back_action] == 'application/overview'
      @flexes = @user.flexes.for_timeline(5)
    else
      @flexes = @user.flexes.for_timeline
    end
    render params[:back_action]
  end

  def discard
    @flex.update_attribute :discarded, true
    flash[:notice] = "You've chucked out that flex."
    if params[:back_action] == 'application/overview'
      redirect_to root_path()
    else
      redirect_to flexes_path(:user_id => @flex.user.id)
    end
  end

  def restore
    @flex.update_attribute :discarded, false
    flash[:notice] = "You've restored that flex."
    if params[:back_action] == 'application/overview'
      redirect_to root_path()
    else
      redirect_to flexes_path(:user_id => @flex.user.id)
    end
  end

  def get_flex
    @flex = Flex.find params[:id]
  end

end
