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

ActiveRecord::Schema.define(version: 2019_09_19_111958) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "assessment_questions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "key", null: false
    t.datetime "disabled_at"
  end

  create_table "ethnicities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "title", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "nomis_code"
    t.datetime "disabled_at"
  end

  create_table "genders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "key", null: false
    t.string "nomis_code"
    t.datetime "disabled_at"
  end

  create_table "identifier_types", id: :string, force: :cascade do |t|
    t.string "title", null: false
    t.string "description"
    t.datetime "disabled_at"
  end

  create_table "locations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.string "location_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "nomis_agency_id"
    t.string "key", null: false
    t.datetime "disabled_at"
  end

  create_table "moves", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "date", null: false
    t.uuid "from_location_id", null: false
    t.uuid "to_location_id"
    t.uuid "person_id", null: false
    t.string "status", default: "requested", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reference", null: false
    t.string "move_type"
    t.string "additional_information"
    t.integer "nomis_event_id"
    t.datetime "time_due"
    t.string "cancellation_reason"
    t.text "cancellation_reason_comment"
    t.index ["reference"], name: "index_moves_on_reference", unique: true
  end

  create_table "nationalities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "key", null: false
    t.datetime "disabled_at"
  end

  create_table "nomis_alerts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type_code", null: false
    t.string "code", null: false
    t.string "description", null: false
    t.string "type_description", null: false
    t.uuid "assessment_question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.bigint "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.bigint "resource_owner_id"
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri"
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "people", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "nomis_prison_number"
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
    t.jsonb "assessment_answers"
    t.jsonb "profile_identifiers"
    t.string "gender_additional_information"
    t.integer "latest_nomis_booking_id"
  end

  add_foreign_key "moves", "locations", column: "from_location_id", name: "fk_rails_moves_from_location_id"
  add_foreign_key "moves", "locations", column: "to_location_id", name: "fk_rails_moves_to_location_id"
  add_foreign_key "moves", "people", name: "fk_rails_moves_person_id"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "profiles", "people", name: "profiles_person_id"
end
