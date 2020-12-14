# frozen_string_literal: true

module Api
  module Reference
    class LocationsController < ApiController
      def index
        locations = Locations::Finder.new(filter_params: filter_params, active_record_relationships: active_record_relationships).call
        paginate locations, serializer: LocationSerializer, include: included_relationships
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
        render_json location, serializer: LocationSerializer, include: included_relationships, status: status
      end

      PERMITTED_FILTER_PARAMS = %i[location_type nomis_agency_id supplier_id location_id region_id young_offender_institution].freeze

      def filter_params
        params.fetch(:filter, {}).permit(PERMITTED_FILTER_PARAMS).to_h
      end

      def supported_relationships
        LocationSerializer::SUPPORTED_RELATIONSHIPS
      end
    end
  end
end
