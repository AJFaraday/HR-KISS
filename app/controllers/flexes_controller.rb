class FlexesController < ApplicationController

  before_filter :get_flex
  before_filter :require_user

  def index
    if current_user.is_admin? and params[:user_id]
      @user = User.find params[:user_id]
    else
      @user = current_user
    end
    @flexes = @user.flexes.for_timeline
  end

  def create

  end

  def discard

  end

  def restore

  end

  def get_flex
    if params[:id]
      @flex = Flex.find params[:id]
    end
  end

end
