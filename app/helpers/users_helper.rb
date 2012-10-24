module UsersHelper

  def user_menu(user=nil)
    items = []
    if user
      unless params[:action] == 'show' or user != current_user
        items << {:text => 'show profile', :url => user_path(user)}
      end
      items << {:text => 'edit profile', :url => edit_user_path(user)} unless params[:action] == 'edit'
    end
    items
  end

end
