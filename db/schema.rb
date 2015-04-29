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

ActiveRecord::Schema.define(version: 20150425080321) do

  create_table "channels", force: :cascade do |t|
    t.string   "title"
    t.integer  "elapsetime"
    t.string   "starttime"
    t.integer  "rows"
    t.string   "defaultname"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contents", force: :cascade do |t|
    t.integer  "channelid"
    t.integer  "tweetstime"
    t.string   "tweets"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.string   "mini"
    t.integer  "interval"
    t.integer  "renew"
    t.integer  "noworder"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.integer  "groupid"
    t.integer  "order"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
