# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_01_18_124654) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
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

  create_table "allocation_complex_cases", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "allocations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "from_location_id", null: false
    t.uuid "to_location_id", null: false
    t.date "date", null: false
    t.string "prisoner_category"
    t.string "sentence_length"
    t.jsonb "complex_cases"
    t.integer "moves_count", null: false
    t.boolean "complete_in_full", default: false, null: false
    t.text "other_criteria"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", null: false
    t.string "cancellation_reason"
    t.text "cancellation_reason_comment"
    t.string "requested_by"
    t.string "estate"
    t.text "sentence_length_comment"
    t.text "estate_comment"
    t.index ["date"], name: "index_allocations_on_date"
  end

  create_table "assessment_questions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "key", null: false
    t.datetime "disabled_at"
  end

  create_table "categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "title", null: false
    t.boolean "move_supported", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["key"], name: "index_categories_on_key", unique: true
  end

  create_table "court_hearings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "move_id"
    t.datetime "start_time", null: false
    t.date "case_start_date"
    t.string "case_type"
    t.text "comments"
    t.string "case_number"
    t.integer "nomis_case_id"
    t.integer "nomis_hearing_id"
    t.boolean "saved_to_nomis", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["move_id"], name: "index_court_hearings_on_move_id"
  end

  create_table "documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "move_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.string "documentable_type"
    t.uuid "documentable_id"
    t.index ["discarded_at"], name: "index_documents_on_discarded_at"
    t.index ["documentable_type", "documentable_id"], name: "index_documents_on_documentable_type_and_documentable_id"
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

  create_table "events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "event_name", null: false
    t.jsonb "details"
    t.datetime "client_timestamp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "eventable_id", null: false
    t.string "eventable_type", null: false
    t.string "type"
    t.text "notes"
    t.uuid "generic_event_id"
    t.index ["client_timestamp"], name: "index_events_on_client_timestamp"
    t.index ["eventable_id", "eventable_type", "event_name"], name: "index_events_on_eventable_id_and_eventable_type_and_event_name"
    t.index ["eventable_id", "eventable_type"], name: "index_events_on_eventable_id_and_eventable_type"
    t.index ["generic_event_id"], name: "index_events_on_generic_event_id"
    t.index ["updated_at"], name: "index_events_on_updated_at"
  end

  create_table "flipper_features", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.string "feature_key", null: false
    t.string "key", null: false
    t.string "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "framework_flags", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "framework_question_id", null: false
    t.string "flag_type", null: false
    t.string "title", null: false
    t.string "question_value", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["framework_question_id"], name: "index_framework_flags_on_framework_question_id"
  end

  create_table "framework_flags_responses", id: false, force: :cascade do |t|
    t.uuid "framework_response_id", null: false
    t.uuid "framework_flag_id", null: false
    t.index ["framework_flag_id"], name: "index_framework_flags_responses_on_framework_flag_id"
    t.index ["framework_response_id"], name: "index_framework_flags_responses_on_framework_response_id"
  end

  create_table "framework_nomis_codes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code_type", null: false
    t.string "code"
    t.boolean "fallback", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "framework_nomis_codes_questions", id: false, force: :cascade do |t|
    t.uuid "framework_question_id"
    t.uuid "framework_nomis_code_id"
    t.index ["framework_nomis_code_id"], name: "index_framework_nomis_codes_questions_on_nomis_code_id"
    t.index ["framework_question_id"], name: "index_framework_nomis_codes_questions_on_question_id"
  end

  create_table "framework_nomis_mappings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "raw_nomis_mapping", null: false
    t.string "code", null: false
    t.string "code_type", null: false
    t.text "code_description"
    t.text "comments"
    t.date "start_date"
    t.date "end_date"
    t.date "creation_date"
    t.date "expiry_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "framework_nomis_mappings_responses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "framework_response_id"
    t.uuid "framework_nomis_mapping_id"
    t.index ["framework_nomis_mapping_id"], name: "index_framework_nomis_mappings_responses_on_nomis_mapping_id"
    t.index ["framework_response_id"], name: "index_framework_nomis_mappings_responses_on_response_id"
  end

  create_table "framework_questions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "framework_id", null: false
    t.string "key", null: false
    t.string "section", null: false
    t.boolean "required", default: false, null: false
    t.string "question_type", null: false
    t.string "options", default: [], array: true
    t.string "dependent_value"
    t.boolean "followup_comment", default: false, null: false
    t.string "followup_comment_options", default: [], array: true
    t.uuid "parent_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "prefill"
    t.index ["framework_id"], name: "index_framework_questions_on_framework_id"
    t.index ["parent_id"], name: "index_framework_questions_on_parent_id"
  end

  create_table "framework_responses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "framework_question_id", null: false
    t.text "value_text"
    t.jsonb "value_json"
    t.string "type", null: false
    t.uuid "parent_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "responded", default: false, null: false
    t.boolean "prefilled", default: false, null: false
    t.uuid "assessmentable_id"
    t.string "assessmentable_type"
    t.string "value_type"
    t.string "section"
    t.string "responded_by"
    t.datetime "responded_at"
    t.index ["assessmentable_type", "assessmentable_id"], name: "index_responses_on_assessmentable_type_and_assessmentable_id"
    t.index ["framework_question_id"], name: "index_framework_responses_on_framework_question_id"
    t.index ["parent_id"], name: "index_framework_responses_on_parent_id"
    t.index ["value_json"], name: "index_framework_responses_on_value_json", using: :gin
  end

  create_table "frameworks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "version", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name", "version"], name: "index_frameworks_on_name_and_version", unique: true
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

  create_table "generic_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "eventable_id", null: false
    t.string "eventable_type", null: false
    t.string "type", null: false
    t.text "notes"
    t.string "created_by"
    t.jsonb "details"
    t.datetime "occurred_at", null: false
    t.datetime "recorded_at", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "supplier_id"
    t.string "classification", default: "default"
    t.index ["eventable_id", "eventable_type", "classification"], name: "index_on_generic_event_classification"
    t.index ["eventable_id", "eventable_type"], name: "index_generic_events_on_eventable_id_and_eventable_type"
    t.index ["occurred_at"], name: "index_generic_events_on_occurred_at"
    t.index ["recorded_at"], name: "index_generic_events_on_recorded_at"
    t.index ["supplier_id"], name: "index_generic_events_on_supplier_id"
  end

  create_table "identifier_types", id: :string, force: :cascade do |t|
    t.string "title", null: false
    t.string "description"
    t.datetime "disabled_at"
  end

  create_table "journeys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "move_id", null: false
    t.uuid "supplier_id", null: false
    t.uuid "from_location_id", null: false
    t.uuid "to_location_id", null: false
    t.boolean "billable", default: false, null: false
    t.string "state", null: false
    t.jsonb "vehicle"
    t.datetime "client_timestamp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_timestamp"], name: "index_journeys_on_client_timestamp"
    t.index ["from_location_id"], name: "index_journeys_on_from_location_id"
    t.index ["move_id", "client_timestamp"], name: "index_journeys_on_move_id_and_client_timestamp"
    t.index ["move_id", "state"], name: "index_journeys_on_move_id_and_state"
    t.index ["move_id"], name: "index_journeys_on_move_id"
    t.index ["state"], name: "index_journeys_on_state"
    t.index ["supplier_id", "billable"], name: "index_journeys_on_supplier_id_and_billable"
    t.index ["supplier_id", "client_timestamp"], name: "index_journeys_on_supplier_id_and_client_timestamp"
    t.index ["supplier_id"], name: "index_journeys_on_supplier_id"
    t.index ["to_location_id"], name: "index_journeys_on_to_location_id"
    t.index ["updated_at"], name: "index_journeys_on_updated_at"
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
    t.uuid "category_id"
    t.boolean "young_offender_institution", default: false
    t.index ["category_id"], name: "index_locations_on_category_id"
    t.index ["young_offender_institution"], name: "index_locations_on_young_offender_institution"
  end

  create_table "locations_regions", id: false, force: :cascade do |t|
    t.uuid "location_id", null: false
    t.uuid "region_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id", "region_id"], name: "index_locations_regions_on_location_id_and_region_id", unique: true
    t.index ["location_id"], name: "index_locations_regions_on_location_id"
    t.index ["region_id", "location_id"], name: "index_locations_regions_on_region_id_and_location_id", unique: true
    t.index ["region_id"], name: "index_locations_regions_on_region_id"
  end

  create_table "moves", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "date"
    t.uuid "from_location_id", null: false
    t.uuid "to_location_id"
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
    t.uuid "profile_id"
    t.uuid "prison_transfer_reason_id"
    t.text "reason_comment"
    t.boolean "move_agreed"
    t.string "move_agreed_by"
    t.date "date_from"
    t.date "date_to"
    t.uuid "allocation_id"
    t.string "rejection_reason"
    t.uuid "original_move_id"
    t.uuid "supplier_id"
    t.index ["allocation_id"], name: "index_moves_on_allocation_id"
    t.index ["created_at"], name: "index_moves_on_created_at"
    t.index ["date"], name: "index_moves_on_date"
    t.index ["prison_transfer_reason_id"], name: "index_moves_on_prison_transfer_reason_id"
    t.index ["reference"], name: "index_moves_on_reference", unique: true
    t.index ["supplier_id"], name: "index_moves_on_supplier_id"
    t.index ["updated_at"], name: "index_moves_on_updated_at"
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

  create_table "notification_types", id: :string, force: :cascade do |t|
    t.string "title", null: false
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
    t.uuid "response_id"
    t.string "notification_type_id", null: false
    t.index ["delivered_at"], name: "index_notifications_on_delivered_at"
    t.index ["discarded_at"], name: "index_notifications_on_discarded_at"
    t.index ["event_type"], name: "index_notifications_on_event_type"
    t.index ["subscription_id"], name: "index_notifications_on_subscription_id"
    t.index ["topic_id"], name: "index_notifications_on_topic_id"
    t.index ["topic_type", "topic_id"], name: "index_notifications_on_topic_type_and_topic_id"
    t.index ["topic_type"], name: "index_notifications_on_topic_type"
    t.index ["updated_at"], name: "index_notifications_on_updated_at"
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
    t.citext "nomis_prison_number"
    t.citext "prison_number"
    t.citext "criminal_records_office"
    t.citext "police_national_computer"
    t.string "first_names"
    t.string "last_name"
    t.date "date_of_birth"
    t.string "gender_additional_information"
    t.uuid "ethnicity_id"
    t.uuid "gender_id"
    t.datetime "last_synced_with_nomis"
    t.integer "latest_nomis_booking_id"
    t.index ["criminal_records_office"], name: "index_people_on_criminal_records_office"
    t.index ["date_of_birth"], name: "index_people_on_date_of_birth"
    t.index ["ethnicity_id"], name: "index_people_on_ethnicity_id"
    t.index ["gender_id"], name: "index_people_on_gender_id"
    t.index ["nomis_prison_number"], name: "index_people_on_nomis_prison_number"
    t.index ["police_national_computer"], name: "index_people_on_police_national_computer"
    t.index ["prison_number"], name: "index_people_on_prison_number"
    t.index ["updated_at"], name: "index_people_on_updated_at"
  end

  create_table "person_escort_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "framework_id", null: false
    t.uuid "profile_id", null: false
    t.string "status", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "confirmed_at"
    t.uuid "move_id"
    t.jsonb "nomis_sync_status", default: [], null: false
    t.uuid "prefill_source_id"
    t.datetime "completed_at"
    t.index ["framework_id"], name: "index_person_escort_records_on_framework_id"
    t.index ["move_id"], name: "index_person_escort_records_on_move_id"
    t.index ["prefill_source_id"], name: "index_person_escort_records_on_prefill_source_id"
    t.index ["profile_id"], name: "index_person_escort_records_on_profile_id", unique: true
  end

  create_table "populations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "location_id", null: false
    t.date "date", null: false
    t.integer "operational_capacity", null: false
    t.integer "usable_capacity", null: false
    t.integer "unlock", null: false
    t.integer "bedwatch", null: false
    t.integer "overnights_in", null: false
    t.integer "overnights_out", null: false
    t.integer "out_of_area_courts", null: false
    t.integer "discharges", null: false
    t.string "updated_by"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["date"], name: "index_populations_on_date"
    t.index ["location_id", "date"], name: "index_on_population_uniqueness", unique: true
    t.index ["location_id"], name: "index_populations_on_location_id"
  end

  create_table "prison_transfer_reasons", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "title", null: false
    t.datetime "disabled_at"
    t.index ["key"], name: "index_prison_transfer_reasons_on_key"
  end

  create_table "profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "person_id", null: false
    t.string "last_name"
    t.string "first_names"
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
    t.string "category"
    t.string "category_code"
    t.uuid "category_id"
    t.boolean "requires_youth_risk_assessment"
    t.index ["category_code"], name: "index_profiles_on_category_code"
    t.index ["category_id"], name: "index_profiles_on_category_id"
    t.index ["updated_at"], name: "index_profiles_on_updated_at"
  end

  create_table "regions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_regions_on_key"
  end

  create_table "subscriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "supplier_id", null: false
    t.string "callback_url"
    t.string "encrypted_secret"
    t.boolean "enabled", default: true, null: false
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email_address"
    t.string "encrypted_username"
    t.string "encrypted_password"
    t.index ["callback_url"], name: "index_subscriptions_on_callback_url"
    t.index ["discarded_at"], name: "index_subscriptions_on_discarded_at"
    t.index ["supplier_id"], name: "index_subscriptions_on_supplier_id"
  end

  create_table "supplier_locations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "supplier_id", null: false
    t.uuid "location_id", null: false
    t.date "effective_from"
    t.date "effective_to"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["effective_from"], name: "index_supplier_locations_on_effective_from"
    t.index ["effective_to"], name: "index_supplier_locations_on_effective_to"
    t.index ["location_id"], name: "index_supplier_locations_on_location_id"
    t.index ["supplier_id"], name: "index_supplier_locations_on_supplier_id"
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
    t.uuid "supplier_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "youth_risk_assessments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "framework_id", null: false
    t.uuid "profile_id", null: false
    t.uuid "move_id", null: false
    t.uuid "prefill_source_id"
    t.string "status", null: false
    t.jsonb "nomis_sync_status", default: [], null: false
    t.datetime "confirmed_at"
    t.datetime "completed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["framework_id"], name: "index_youth_risk_assessments_on_framework_id"
    t.index ["move_id"], name: "index_youth_risk_assessments_on_move_id"
    t.index ["prefill_source_id"], name: "index_youth_risk_assessments_on_prefill_source_id"
    t.index ["profile_id"], name: "index_youth_risk_assessments_on_profile_id", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "allocations", "locations", column: "from_location_id", name: "fk_rails_allocations_from_location_id"
  add_foreign_key "allocations", "locations", column: "to_location_id", name: "fk_rails_allocations_to_location_id"
  add_foreign_key "court_hearings", "moves"
  add_foreign_key "documents", "moves"
  add_foreign_key "events", "generic_events"
  add_foreign_key "framework_flags", "framework_questions"
  add_foreign_key "framework_questions", "frameworks"
  add_foreign_key "framework_responses", "framework_questions"
  add_foreign_key "generic_events", "suppliers"
  add_foreign_key "journeys", "locations", column: "from_location_id"
  add_foreign_key "journeys", "locations", column: "to_location_id"
  add_foreign_key "journeys", "moves"
  add_foreign_key "journeys", "suppliers"
  add_foreign_key "locations", "categories"
  add_foreign_key "locations_regions", "locations"
  add_foreign_key "locations_regions", "regions"
  add_foreign_key "moves", "allocations"
  add_foreign_key "moves", "locations", column: "from_location_id", name: "fk_rails_moves_from_location_id"
  add_foreign_key "moves", "locations", column: "to_location_id", name: "fk_rails_moves_to_location_id"
  add_foreign_key "moves", "moves", column: "original_move_id"
  add_foreign_key "moves", "suppliers"
  add_foreign_key "notifications", "notification_types"
  add_foreign_key "notifications", "subscriptions"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "person_escort_records", "frameworks"
  add_foreign_key "person_escort_records", "moves"
  add_foreign_key "person_escort_records", "profiles"
  add_foreign_key "populations", "locations"
  add_foreign_key "profiles", "categories"
  add_foreign_key "profiles", "people", name: "profiles_person_id"
  add_foreign_key "subscriptions", "suppliers"
  add_foreign_key "supplier_locations", "locations"
  add_foreign_key "supplier_locations", "suppliers"
  add_foreign_key "versions", "suppliers"
  add_foreign_key "youth_risk_assessments", "frameworks"
  add_foreign_key "youth_risk_assessments", "moves"
  add_foreign_key "youth_risk_assessments", "profiles"
end
