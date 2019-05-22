# frozen_string_literal: true

module Locations
  class Finder
    attr_accessor :filter_params

    def initialize(filter_params)
      self.filter_params = filter_params
    end

    def call
      Location.where(filter_params.slice(:location_type))
    end
  end
end
