module AbsencesHelper

  def absence_menu(absence=nil)
    result = []
    result << {:text => 'absences', :url => absence_path} unless params[:action] == 'index'
    result << {:text => 'book absence', :url => new_absence_path} unless params[:action] == 'new'
    if absence
      result << {:text => 'show absence', :url => absence_path(absence)} unless params[:action] == 'show'
      result << {:text => 'edit absences', :url => edit_absence_path(absence)} unless params[:action] == 'edit'
    end
    result
  end

end
