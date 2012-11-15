module UsersHelper

  def user_menu(user=nil)
    items = []
    if user
      unless params[:action] == 'show' or user != current_user
        items << {:text => 'Show Profile', :url => user_path(user)}
      end
      items << {:text => 'Edit Profile', :url => edit_user_path(user)} unless params[:action] == 'edit'
      items << {:text => 'Delete This Profile',
                :url => user_path(user),
                :extra => {:method => :delete,
                           :confirm => "Do you really want to delete this user, their absences and flexes?"}} if current_user.is_admin?
    end
    items
  end

end
