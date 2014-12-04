class CreateNouns < ActiveRecord::Migration
  def change
    execute "create extension hstore"
    create_table :nouns do |t|
      t.string :name
      t.integer :parent_id, index: true
      t.text :description
      t.date :aquired_on
      t.decimal :cost, :precision => 8, :scale => 2, :default => 0.0
      t.decimal :value, :precision => 8, :scale => 2, :default => 0.0
      t.integer :lft, index: true
      t.integer :rgt, index: true
      t.integer :depth, index: true
      t.hstore :properties

      t.timestamps null: false
    end

  end
end
