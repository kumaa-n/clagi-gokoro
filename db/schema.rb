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

ActiveRecord::Schema[7.2].define(version: 2026_01_20_161122) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "review_favorites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "review_uuid", null: false
    t.index ["review_uuid"], name: "index_review_favorites_on_review_uuid"
    t.index ["user_id", "review_uuid"], name: "index_review_favorites_on_user_id_and_review_uuid", unique: true
    t.index ["user_id"], name: "index_review_favorites_on_user_id"
  end

  create_table "reviews", primary_key: "uuid", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "tempo_rating", null: false
    t.integer "fingering_technique_rating", null: false
    t.integer "plucking_technique_rating", null: false
    t.integer "expression_rating", null: false
    t.integer "memorization_rating", null: false
    t.decimal "overall_rating", null: false
    t.text "summary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "song_uuid", null: false
    t.text "tags", default: [], array: true
    t.index ["song_uuid"], name: "index_reviews_on_song_uuid"
    t.index ["user_id", "song_uuid"], name: "index_reviews_on_user_id_and_song_uuid", unique: true
    t.index ["user_id"], name: "index_reviews_on_user_id"
    t.index ["uuid"], name: "index_reviews_on_uuid", unique: true
  end

  create_table "songs", primary_key: "uuid", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.string "composer"
    t.string "arranger"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "normalized_title"
    t.string "normalized_composer"
    t.string "normalized_arranger"
    t.index ["composer"], name: "index_songs_on_composer"
    t.index ["normalized_arranger"], name: "index_songs_on_normalized_arranger"
    t.index ["normalized_composer"], name: "index_songs_on_normalized_composer"
    t.index ["normalized_title"], name: "index_songs_on_normalized_title"
    t.index ["title"], name: "index_songs_on_title"
    t.index ["uuid"], name: "index_songs_on_uuid", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name", null: false
    t.text "self_introduction"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "provider"
    t.string "provider_uid"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true, where: "((email IS NOT NULL) AND ((email)::text <> ''::text))"
    t.index ["name"], name: "index_users_on_name", unique: true
    t.index ["provider", "provider_uid"], name: "index_users_on_provider_and_provider_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "review_favorites", "reviews", column: "review_uuid", primary_key: "uuid"
  add_foreign_key "review_favorites", "users"
  add_foreign_key "reviews", "songs", column: "song_uuid", primary_key: "uuid"
  add_foreign_key "reviews", "users"
end
