# frozen_string_literal: true

module Regions
  class Importer
    attr_accessor :items

    def initialize(items)
      self.items = items.with_indifferent_access
    end

    def call
      items.each do |key, details|
        region = Region.find_or_initialize_by(key: key.to_s)
        region.locations = Location.where(nomis_agency_id: details[:locations])
        region.update!(name: details[:name])
      end
    end
  end
end
