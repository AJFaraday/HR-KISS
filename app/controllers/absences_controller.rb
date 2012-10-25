class AbsencesController < ApplicationController

  before_filter :require_user

  def index
    if current_user.is_admin?
      @absences = Absence.all # TODO limit to future, add parameters for archive
    else
      @absences = Absence.all(:conditions => ['user_id = ?', current_user.id])
    end
  end

end
