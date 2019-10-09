# frozen_string_literal: true

module Locations
  class Finder
    attr_accessor :filter_params

    def initialize(filter_params)
      self.filter_params = filter_params
    end

    def call
      Location.where(filter_params.slice(:location_type, :nomis_agency_id, :supplier_ids)).includes(:suppliers)
    end
  end
end
