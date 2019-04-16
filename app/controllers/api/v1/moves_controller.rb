# frozen_string_literal: true

module Api
  module V1
    class MovesController < ApiController
      def index
        render(
          json: Moves::MoveFinder.new(filter_params).call,
          include: {
            person: %I[forenames surname date_of_birth],
            from_location: %I[location_type label],
            to_location: %I[location_type label]
          }
        )
      end

      private

      PERMITTED_FILTER_PARAMS = %i[date_from date_to from_location_id location_type status].freeze

      def filter_params
        params.fetch(:filter, {}).permit(PERMITTED_FILTER_PARAMS).to_h
      end
    end
  end
end
