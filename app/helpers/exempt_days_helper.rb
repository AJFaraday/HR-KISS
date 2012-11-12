module ExemptDaysHelper

  def exempt_day_menu(absence=nil)
    result = []
    result << {:text => 'New Exempt Day', :url => new_exempt_day_path} unless params[:action] == 'new'

    if absence and !absence.new_record?
      result << {:text => 'Edit', :url => edit_exempt_day_path(absence)} unless params[:action] == 'edit'
    end
    result
  end
  
end
