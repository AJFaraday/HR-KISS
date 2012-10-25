class AddLineManagerAndSickDaysToUser < ActiveRecord::Migration
  def change
    add_column :users, :sick_day_allowance, :float
    add_column :users, :line_manager_id, :integer
  end
end
