class CreateFlexes < ActiveRecord::Migration
  def change
    create_table :flexes do |t|
      t.boolean :positive
      t.integer :hours
      t.integer :minutes
      t.string :comment
      t.integer :position
      t.integer :total_hours
      t.integer :total_minutes
      t.boolean :discarded
      t.integer :user_id

      t.timestamps
    end
  end
end
