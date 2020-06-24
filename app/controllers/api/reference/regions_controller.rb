# frozen_string_literal: true

module Api
  module Reference
    class RegionsController < ApiController
      def index
        render json: Region.all.includes(locations: :suppliers), include: included_relationships
      end

    private

      def supported_relationships
        RegionSerializer::SUPPORTED_RELATIONSHIPS
      end
    end
  end
end
