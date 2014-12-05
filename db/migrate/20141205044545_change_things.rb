class ChangeThings < ActiveRecord::Migration
  def change
    rename_column :things, :aquired_on, :acquired_on
  end
end
