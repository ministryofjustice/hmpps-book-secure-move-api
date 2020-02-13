# frozen_string_literal: true

module Locations
  class Importer
    attr_accessor :items

    def initialize(items)
      self.items = items
    end

    def call
      items.each do |location|
        Location
          .find_or_initialize_by(nomis_agency_id: location[:nomis_agency_id])
          .update(location.slice(:title, :location_type, :key, :can_upload_documents))
      end
    end
  end
end
