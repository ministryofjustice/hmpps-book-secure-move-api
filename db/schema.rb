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

ActiveRecord::Schema.define(version: 2019_05_23_071601) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "genders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "description", null: false
    t.string "location_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "location_code"
  end

  create_table "moves", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "date", null: false
    t.uuid "from_location_id", null: false
    t.uuid "to_location_id", null: false
    t.uuid "person_id", null: false
    t.string "move_type", null: false
    t.string "status", null: false
    t.time "time_due", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "nationalities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "people", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "profile_attribute_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "description", null: false
    t.string "category", null: false
    t.string "user_type", null: false
    t.string "alert_type"
    t.string "alert_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "person_id", null: false
    t.string "last_name", null: false
    t.string "first_names", null: false
    t.date "date_of_birth"
    t.string "aliases", default: [], array: true
    t.uuid "gender_id"
    t.uuid "ethnicity_id"
    t.uuid "nationality_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "moves", "locations", column: "from_location_id", name: "fk_rails_moves_from_location_id"
  add_foreign_key "moves", "locations", column: "to_location_id", name: "fk_rails_moves_to_location_id"
  add_foreign_key "moves", "people", name: "fk_rails_moves_person_id"
  add_foreign_key "profiles", "people", name: "profiles_person_id"
end
