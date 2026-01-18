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

ActiveRecord::Schema[8.0].define(version: 2026_01_18_174954) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "betting_pool_memberships", force: :cascade do |t|
    t.bigint "betting_pool_id", null: false
    t.bigint "user_id", null: false
    t.string "role", default: "member", null: false
    t.datetime "joined_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["betting_pool_id", "user_id"], name: "index_betting_pool_memberships_on_betting_pool_id_and_user_id", unique: true
    t.index ["betting_pool_id"], name: "index_betting_pool_memberships_on_betting_pool_id"
    t.index ["user_id"], name: "index_betting_pool_memberships_on_user_id"
  end

  create_table "betting_pools", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "event_id", null: false
    t.bigint "creator_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_betting_pools_on_creator_id"
    t.index ["event_id", "creator_id"], name: "index_betting_pools_on_event_id_and_creator_id"
    t.index ["event_id"], name: "index_betting_pools_on_event_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_events_on_name", unique: true
  end

  create_table "matches", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "team1_id"
    t.bigint "team2_id"
    t.integer "score1"
    t.integer "score2"
    t.datetime "match_date", null: false
    t.integer "round"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "match_date"], name: "index_matches_on_event_id_and_match_date"
    t.index ["event_id"], name: "index_matches_on_event_id"
    t.index ["team1_id"], name: "index_matches_on_team1_id"
    t.index ["team2_id"], name: "index_matches_on_team2_id"
  end

  create_table "predictions", force: :cascade do |t|
    t.bigint "betting_pool_id", null: false
    t.bigint "match_id", null: false
    t.bigint "user_id", null: false
    t.integer "predicted_score1", null: false
    t.integer "predicted_score2", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["betting_pool_id", "match_id", "user_id"], name: "index_predictions_on_betting_pool_id_and_match_id_and_user_id", unique: true
    t.index ["betting_pool_id"], name: "index_predictions_on_betting_pool_id"
    t.index ["match_id"], name: "index_predictions_on_match_id"
    t.index ["user_id"], name: "index_predictions_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name", null: false
    t.string "country_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_code"], name: "index_teams_on_country_code", unique: true
    t.index ["name"], name: "index_teams_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "betting_pool_memberships", "betting_pools"
  add_foreign_key "betting_pool_memberships", "users"
  add_foreign_key "betting_pools", "events"
  add_foreign_key "betting_pools", "users", column: "creator_id"
  add_foreign_key "matches", "events"
  add_foreign_key "matches", "teams", column: "team1_id"
  add_foreign_key "matches", "teams", column: "team2_id"
  add_foreign_key "predictions", "betting_pools"
  add_foreign_key "predictions", "matches"
  add_foreign_key "predictions", "users"
  add_foreign_key "sessions", "users"
end
