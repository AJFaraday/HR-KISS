class RenameTypeOfAbsence < ActiveRecord::Migration
  def up
    rename_column :absences, :type, :variety
  end

  def down
    rename_column :absences, :variety, :type
  end
end
