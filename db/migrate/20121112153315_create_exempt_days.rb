class CreateExemptDays < ActiveRecord::Migration
  def change
    create_table :exempt_days do |t|
      t.string :name
      t.date :day

      t.timestamps
    end
  end
end
