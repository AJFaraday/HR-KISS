class AddSickDayRemainingToUser < ActiveRecord::Migration
  def change
    add_column :users, :sick_days_remaining, :float
  end
end
