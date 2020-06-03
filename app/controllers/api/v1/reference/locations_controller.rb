# frozen_string_literal: true

module Api
  module V1
    module Reference
      class LocationsController < ApiController
        def index
          types = Locations::Finder.new(filter_params).call
          paginate types, include: %w[suppliers]
        end

        def show
          location = find_location
          render_location(location, 200)
        end

      private

        def find_location
          Location.find(params[:id])
        end

        def render_location(location, status)
          render json: location, status: status, include: %w[suppliers]
        end

        PERMITTED_FILTER_PARAMS = %i[location_type nomis_agency_id supplier_id].freeze

        def filter_params
          params.fetch(:filter, {}).permit(PERMITTED_FILTER_PARAMS).to_h
        end
      end
    end
  end
end
