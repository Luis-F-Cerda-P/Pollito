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

ActiveRecord::Schema[8.1].define(version: 2026_01_21_224350) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "betting_pool_memberships", force: :cascade do |t|
    t.bigint "betting_pool_id", null: false
    t.datetime "created_at", null: false
    t.datetime "joined_at", null: false
    t.string "role", default: "member", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["betting_pool_id", "user_id"], name: "index_betting_pool_memberships_on_betting_pool_id_and_user_id", unique: true
    t.index ["betting_pool_id"], name: "index_betting_pool_memberships_on_betting_pool_id"
    t.index ["user_id"], name: "index_betting_pool_memberships_on_user_id"
  end

  create_table "betting_pools", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "creator_id", null: false
    t.bigint "event_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_betting_pools_on_creator_id"
    t.index ["event_id", "creator_id"], name: "index_betting_pools_on_event_id_and_creator_id"
    t.index ["event_id"], name: "index_betting_pools_on_event_id"
  end

  create_table "events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.date "end_date"
    t.string "name", null: false
    t.date "start_date"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_events_on_name", unique: true
  end

  create_table "match_participants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "match_id", null: false
    t.integer "participant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id"], name: "index_match_participants_on_match_id"
    t.index ["participant_id"], name: "index_match_participants_on_participant_id"
  end

  create_table "matches", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "match_date"
    t.integer "match_status"
    t.integer "round"
    t.datetime "updated_at", null: false
    t.index ["event_id", "match_date"], name: "index_matches_on_event_id_and_match_date"
    t.index ["event_id"], name: "index_matches_on_event_id"
  end

  create_table "participants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_participants_on_name", unique: true
  end

  create_table "predicted_results", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "match_participant_id", null: false
    t.integer "prediction_id", null: false
    t.integer "score", null: false
    t.datetime "updated_at", null: false
    t.index ["match_participant_id"], name: "index_predicted_results_on_match_participant_id"
    t.index ["prediction_id", "match_participant_id"], name: "index_predicted_results_on_prediction_and_participant", unique: true
    t.index ["prediction_id"], name: "index_predicted_results_on_prediction_id"
  end

  create_table "predictions", force: :cascade do |t|
    t.bigint "betting_pool_id", null: false
    t.datetime "created_at", null: false
    t.bigint "match_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["betting_pool_id", "match_id", "user_id"], name: "index_predictions_on_user_pool_match", unique: true
    t.index ["betting_pool_id"], name: "index_predictions_on_betting_pool_id"
    t.index ["match_id"], name: "index_predictions_on_match_id"
    t.index ["user_id"], name: "index_predictions_on_user_id"
  end

  create_table "results", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "final", default: false, null: false
    t.integer "match_participant_id", null: false
    t.integer "score"
    t.datetime "updated_at", null: false
    t.index ["match_participant_id"], name: "index_results_on_match_participant_id", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "betting_pool_memberships", "betting_pools"
  add_foreign_key "betting_pool_memberships", "users"
  add_foreign_key "betting_pools", "events"
  add_foreign_key "betting_pools", "users", column: "creator_id"
  add_foreign_key "match_participants", "matches"
  add_foreign_key "match_participants", "participants"
  add_foreign_key "matches", "events"
  add_foreign_key "predicted_results", "match_participants"
  add_foreign_key "predicted_results", "predictions"
  add_foreign_key "predictions", "betting_pools"
  add_foreign_key "predictions", "matches"
  add_foreign_key "predictions", "users"
  add_foreign_key "results", "match_participants"
  add_foreign_key "sessions", "users"
end
