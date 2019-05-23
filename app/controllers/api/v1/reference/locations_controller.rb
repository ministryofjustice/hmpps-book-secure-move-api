# frozen_string_literal: true

module Api
  module V1
    module Reference
      class LocationsController < ApiController
        def index
          types = Locations::Finder.new(filter_params).call
          paginate types
        end

        private

        PERMITTED_FILTER_PARAMS = %i[location_type].freeze

        def filter_params
          params.fetch(:filter, {}).permit(PERMITTED_FILTER_PARAMS).to_h
        end
      end
    end
  end
end
