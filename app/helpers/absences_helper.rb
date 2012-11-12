module AbsencesHelper

  def absence_menu(absence=nil)
    result = []
    result << {:text => 'Absence Calendar', :url => calendar_absences_path} unless params[:action] == 'calendar'
    result << {:text => 'Absence List', :url => absences_path} unless params[:action] == 'index'
    result << {:text => 'Book Absence', :url => new_absence_path} unless params[:action] == 'new'

    if absence and !absence.new_record?
      result << {:text => 'Show this Absence', :url => absence_path(absence)} unless params[:action] == 'show'
      result << {:text => 'Edit this Absence', :url => edit_absence_path(absence)} unless params[:action] == 'edit'
    end
    result << {:text => "Export Absences", :url => export_absences_path}
    result
  end

end
