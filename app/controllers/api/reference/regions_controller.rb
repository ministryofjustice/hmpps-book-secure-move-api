# frozen_string_literal: true

module Api
  module Reference
    class RegionsController < ApiController
      def index
        regions = Region.all.includes(locations: :suppliers)
        render_json regions, serializer: RegionSerializer, include: included_relationships
      end

      def show
        region = Region.find(params[:id])
        render_json region, serializer: RegionSerializer, include: included_relationships
      end

    private

      def supported_relationships
        RegionSerializer::SUPPORTED_RELATIONSHIPS
      end
    end
  end
end
