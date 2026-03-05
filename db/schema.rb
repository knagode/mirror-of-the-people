# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_03_05_115321) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "matches", force: :cascade do |t|
    t.integer "wish_id", null: false
    t.integer "party_id", null: false
    t.float "score"
    t.text "explanation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["party_id"], name: "index_matches_on_party_id"
    t.index ["wish_id"], name: "index_matches_on_wish_id"
  end

  create_table "parties", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.text "program"
    t.string "logo_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "profiles", force: :cascade do |t|
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_profiles_on_token", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.bigint "wish_id", null: false
    t.integer "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "profile_id"
    t.index ["profile_id"], name: "index_votes_on_profile_id"
    t.index ["wish_id"], name: "index_votes_on_wish_id"
  end

  create_table "wishes", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "profile_id"
    t.index ["profile_id"], name: "index_wishes_on_profile_id"
  end

  add_foreign_key "matches", "parties"
  add_foreign_key "matches", "wishes"
  add_foreign_key "votes", "profiles"
  add_foreign_key "votes", "wishes"
  add_foreign_key "wishes", "profiles"
end
