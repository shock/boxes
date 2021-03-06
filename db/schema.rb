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

ActiveRecord::Schema.define(version: 20150227120032) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "audits", force: true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         default: 0
    t.string   "comment"
    t.string   "remote_address"
    t.string   "request_uuid"
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], name: "associated_index", using: :btree
  add_index "audits", ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
  add_index "audits", ["created_at"], name: "index_audits_on_created_at", using: :btree
  add_index "audits", ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
  add_index "audits", ["user_id", "user_type"], name: "user_index", using: :btree

  create_table "nouns", force: true do |t|
    t.string "name"
  end

  add_index "nouns", ["name"], name: "index_nouns_on_name", unique: true, using: :btree

  create_table "tags", force: true do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.text     "description"
  end

  create_table "thing_tags", force: true do |t|
    t.integer  "thing_id"
    t.integer  "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "thing_tags", ["tag_id"], name: "index_thing_tags_on_tag_id", using: :btree
  add_index "thing_tags", ["thing_id"], name: "index_thing_tags_on_thing_id", using: :btree

  create_table "things", force: true do |t|
    t.text     "name"
    t.integer  "parent_id"
    t.text     "description"
    t.date     "acquired_on"
    t.decimal  "cost",        precision: 8, scale: 2, default: 0.0
    t.decimal  "value",       precision: 8, scale: 2, default: 0.0
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "tree_depth"
    t.hstore   "properties"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.integer  "flags"
    t.integer  "user_id"
  end

  add_index "things", ["lft"], name: "index_things_on_lft", using: :btree
  add_index "things", ["parent_id"], name: "index_things_on_parent_id", using: :btree
  add_index "things", ["rgt"], name: "index_things_on_rgt", using: :btree
  add_index "things", ["tree_depth"], name: "index_things_on_tree_depth", using: :btree
  add_index "things", ["user_id"], name: "index_things_on_user_id", using: :btree

end
