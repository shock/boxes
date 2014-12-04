# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141204182232) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "nouns", force: true do |t|
    t.text     "name"
    t.integer  "parent_id"
    t.text     "description"
    t.date     "aquired_on"
    t.decimal  "cost",        precision: 8, scale: 2, default: 0.0
    t.decimal  "value",       precision: 8, scale: 2, default: 0.0
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "depth"
    t.hstore   "properties"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.integer  "flags"
    t.integer  "user_id"
  end

  add_index "nouns", ["depth"], name: "index_nouns_on_depth", using: :btree
  add_index "nouns", ["lft"], name: "index_nouns_on_lft", using: :btree
  add_index "nouns", ["parent_id"], name: "index_nouns_on_parent_id", using: :btree
  add_index "nouns", ["rgt"], name: "index_nouns_on_rgt", using: :btree
  add_index "nouns", ["user_id"], name: "index_nouns_on_user_id", using: :btree

end
