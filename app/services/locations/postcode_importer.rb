# frozen_string_literal: true

module Locations
  class PostcodeImporter
    attr_accessor :data, :ignored_locations, :errored_locations

    def initialize(data)
      @data = data
      @ignored_locations = []
      @errored_locations = []
    end

    def call
      import_postcodes
    end

  private

    def import_postcodes
      data.map.with_index do |row, i|
        log "\r#{i + 1}/#{data.count}"

        nomis_agency_id = row['nomis_agency_id']
        location = Location.find_by(nomis_agency_id: nomis_agency_id)
        if location.nil? || location.discarded? || location.prison?
          ignore_location(nomis_agency_id, location)
        else
          update_location(nomis_agency_id, location, row['postcode'])
        end
      end
    end

    def ignore_location(nomis_agency_id, location)
      reason = "#{'(not found)' if location.nil?}#{'(disabled)' if location&.discarded?}#{'(prison)' if location&.prison?}"
      log "\nIgnoring: #{nomis_agency_id} #{reason}\n"

      ignored_locations << nomis_agency_id
    end

    def update_location(nomis_agency_id, location, postcode)
      location.update(postcode: postcode)
    rescue Geocoder::InvalidRequest => e
      log "\nError geocoding: #{nomis_agency_id} #{e.message}\n"

      errored_locations << nomis_agency_id
    end

    def log(message)
      print(message) unless Rails.env.test? # rubocop:disable Rails/Output
    end
  end
end
