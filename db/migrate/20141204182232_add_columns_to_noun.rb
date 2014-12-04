class AddColumnsToNoun < ActiveRecord::Migration
  def change
    add_column :nouns, :flags, :integer
    add_column :nouns, :user_id, :integer
    add_index :nouns, :user_id
  end
end
