class ModifyUserTable < ActiveRecord::Migration
  def up
    rename_column :users, :username, :login
    add_column :users, :name, :string
    add_column :users, :admin, :boolean
    add_column :users, :holiday_allowance, :float
    add_column :users, :holiday_remaining, :float
  end

  def down
    rename_column :users, :login, :username
    remove_column :users, :name
    remove_column :users, :admin
    remove_column :users, :holiday_allowance
    remove_column :users, :holiday_remaining
  end
end
