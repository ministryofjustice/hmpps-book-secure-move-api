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

ActiveRecord::Schema.define(version: 2020_02_19_105356) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "assessment_questions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "key", null: false
    t.datetime "disabled_at"
  end

  create_table "documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "move_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_documents_on_discarded_at"
    t.index ["move_id"], name: "index_documents_on_move_id"
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
    t.boolean "can_upload_documents", default: false, null: false
  end

  create_table "locations_suppliers", id: false, force: :cascade do |t|
    t.uuid "location_id", null: false
    t.uuid "supplier_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id", "supplier_id"], name: "index_locations_suppliers_on_location_id_and_supplier_id", unique: true
    t.index ["location_id"], name: "index_locations_suppliers_on_location_id"
    t.index ["supplier_id", "location_id"], name: "index_locations_suppliers_on_supplier_id_and_location_id", unique: true
    t.index ["supplier_id"], name: "index_locations_suppliers_on_supplier_id"
  end

  create_table "moves", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "date", null: false
    t.uuid "from_location_id", null: false
    t.uuid "to_location_id"
    t.uuid "person_id"
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
    t.integer "nomis_event_ids", default: [], null: false, array: true
    t.uuid "profile_id", null: false
    t.uuid "reason_id"
    t.text "reason_comment"
    t.boolean "agreed", default: false
    t.string "agreed_by"
    t.index ["from_location_id", "to_location_id", "person_id", "date"], name: "index_on_move_uniqueness", unique: true
    t.index ["from_location_id", "to_location_id", "profile_id", "date"], name: "index_move_loc_profile_date", unique: true
    t.index ["reason_id"], name: "index_moves_on_reason_id"
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

  create_table "notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "subscription_id", null: false
    t.string "event_type", null: false
    t.uuid "topic_id", null: false
    t.string "topic_type", null: false
    t.integer "delivery_attempts", default: 0, null: false
    t.datetime "delivery_attempted_at"
    t.datetime "delivered_at"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["delivered_at"], name: "index_notifications_on_delivered_at"
    t.index ["discarded_at"], name: "index_notifications_on_discarded_at"
    t.index ["event_type"], name: "index_notifications_on_event_type"
    t.index ["subscription_id"], name: "index_notifications_on_subscription_id"
    t.index ["topic_id"], name: "index_notifications_on_topic_id"
    t.index ["topic_type", "topic_id"], name: "index_notifications_on_topic_type_and_topic_id"
    t.index ["topic_type"], name: "index_notifications_on_topic_type"
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
    t.uuid "owner_id"
    t.string "owner_type"
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "people", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "nomis_prison_number"
    t.index ["nomis_prison_number"], name: "index_people_on_nomis_prison_number"
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

  create_table "reasons", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "title", null: false
    t.index ["key"], name: "index_reasons_on_key"
  end

  create_table "subscriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "supplier_id", null: false
    t.string "callback_url", null: false
    t.string "encrypted_secret"
    t.boolean "enabled", default: true, null: false
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["callback_url"], name: "index_subscriptions_on_callback_url"
    t.index ["discarded_at"], name: "index_subscriptions_on_discarded_at"
    t.index ["supplier_id"], name: "index_subscriptions_on_supplier_id"
  end

  create_table "suppliers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_suppliers_on_key"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.uuid "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "documents", "moves"
  add_foreign_key "locations_suppliers", "locations"
  add_foreign_key "locations_suppliers", "suppliers"
  add_foreign_key "moves", "locations", column: "from_location_id", name: "fk_rails_moves_from_location_id"
  add_foreign_key "moves", "locations", column: "to_location_id", name: "fk_rails_moves_to_location_id"
  add_foreign_key "moves", "profiles"
  add_foreign_key "notifications", "subscriptions"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "profiles", "people", name: "profiles_person_id"
  add_foreign_key "subscriptions", "suppliers"
end
