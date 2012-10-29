module AbsencesHelper

  def absence_menu(absence=nil)
    result = []
    result << {:text => 'Book Absence', :url => new_absence_path} unless params[:action] == 'new'
    if absence and !absence.new_record?
      result << {:text => 'Show Absence', :url => absence_path(absence)} unless params[:action] == 'show'
      result << {:text => 'Edit Absences', :url => edit_absence_path(absence)} unless params[:action] == 'edit'
    end
    result
  end

end
