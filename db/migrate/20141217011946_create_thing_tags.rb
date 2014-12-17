class CreateThingTags < ActiveRecord::Migration
  def change
    create_table :thing_tags do |t|
      t.integer :thing_id
      t.integer :tag_id
      t.timestamps null: false
    end
    add_index :thing_tags, :tag_id
    add_index :thing_tags, :thing_id
  end
end
