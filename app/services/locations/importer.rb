# frozen_string_literal: true

module Locations
  class Importer
    attr_accessor :locations, :location_details, :added_locations, :updated_locations, :disabled_locations

    def initialize(locations, location_details)
      @locations = locations
      @location_details = location_details
      @added_locations = []
      @updated_locations = []
      @disabled_locations = []
    end

    def call
      update_locations
      disable_unused_locations
    end

  private

    def update_locations
      # NB: the `GET /agencies` endpoint will only return active locations - so any locations which we have which are no
      # longer in the endpoint should be marked as disabled. Ignore the "active" flag returned by Nomis.
      locations.each do |item|
        agency_id = item[:nomis_agency_id]
        location = Location.find_or_initialize_by(nomis_agency_id: agency_id)
        address_attributes = location_details[agency_id]

        location.assign_attributes(item.slice(:title, :location_type, :key, :can_upload_documents))
        location.assign_attributes(address_attributes) if address_attributes.present?
        location.disabled_at = nil

        if location.new_record?
          added_locations << location.nomis_agency_id
        elsif location.changed?
          updated_locations << location.nomis_agency_id
        end

        location.save # rubocop:disable Rails/SaveBang
      end
    end

    def disable_unused_locations
      active_agency_ids = locations.map { |item| item[:nomis_agency_id] }
      Location.where.not(nomis_agency_id: active_agency_ids).find_each do |location|
        if location.kept?
          disabled_locations << location.nomis_agency_id
          location.discard
        end
      end
    end
  end
end
