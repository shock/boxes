class AddColumnsToNoun < ActiveRecord::Migration
  def change
    add_column :things, :flags, :integer
    add_column :things, :user_id, :integer
    add_index :things, :user_id
  end
end
