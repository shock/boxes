class CreateNoun < ActiveRecord::Migration
  def change
    create_table :nouns do |t|
      t.string :name
    end
    add_index :nouns, :name, unique: true
  end
end
