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

ActiveRecord::Schema.define(version: 20151129093321) do

  create_table "accounts", force: :cascade do |t|
    t.string   "account_name",    limit: 255
    t.string   "remote_ip",       limit: 255
    t.string   "owner_key",       limit: 255
    t.string   "active_key",      limit: 255
    t.string   "referer",         limit: 255
    t.integer  "referer_percent", limit: 4,   default: 0
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "register",        limit: 255
    t.string   "membership",      limit: 255, default: "basic"
  end

  add_index "accounts", ["account_name"], name: "index_accounts_on_account_name", using: :btree
  add_index "accounts", ["referer", "membership"], name: "index_accounts_on_referer_and_membership", using: :btree
  add_index "accounts", ["referer"], name: "index_accounts_on_referer", using: :btree
  add_index "accounts", ["remote_ip"], name: "index_accounts_on_remote_ip", using: :btree

  create_table "referer_stats", force: :cascade do |t|
    t.string   "referer_name",  limit: 255
    t.integer  "lifetime",      limit: 4,   default: 0
    t.integer  "annual",        limit: 4,   default: 0
    t.integer  "basic",         limit: 4,   default: 0
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "start_percent", limit: 4,   default: 0
  end

  add_index "referer_stats", ["referer_name"], name: "index_referer_stats_on_referer_name", using: :btree

end
