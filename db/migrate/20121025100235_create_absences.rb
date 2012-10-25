class CreateAbsences < ActiveRecord::Migration
  def change
    create_table :absences do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.string :type
      t.text :reason
      t.string :status
      t.float :days
      t.integer :user_id

      t.timestamps
    end
  end
end
