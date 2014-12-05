class ChangeDepthColumn < ActiveRecord::Migration
  def change
    rename_column :things, :depth, :tree_depth
  end
end
