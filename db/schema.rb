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

ActiveRecord::Schema.define(version: 20150823211404) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "builds", force: :cascade do |t|
    t.integer  "build_number", limit: 8
    t.text     "user"
    t.float    "build_time"
    t.datetime "queued_at"
    t.datetime "stop_time"
  end

  add_index "builds", ["build_number"], name: "index_builds_on_build_number", using: :btree

  create_table "test_failures", force: :cascade do |t|
    t.integer  "test_file_id"
    t.integer  "build_num"
    t.text     "digest"
    t.text     "error"
    t.text     "test"
    t.float    "run_time"
    t.datetime "timestamp"
  end

  add_index "test_failures", ["build_num"], name: "index_test_failures_on_build_num", using: :btree
  add_index "test_failures", ["digest"], name: "index_test_failures_on_digest", using: :btree
  add_index "test_failures", ["test_file_id", "build_num"], name: "index_test_failures_on_test_file_id_and_build_num", using: :btree
  add_index "test_failures", ["test_file_id"], name: "index_test_failures_on_test_file_id", using: :btree

  create_table "test_files", force: :cascade do |t|
    t.text     "path"
    t.integer  "total_failures", limit: 8
    t.integer  "first_build"
    t.datetime "last_failure"
    t.datetime "first_failure"
  end

  add_index "test_files", ["first_build"], name: "index_test_files_on_first_build", using: :btree
  add_index "test_files", ["path"], name: "index_test_files_on_path", using: :btree

end
