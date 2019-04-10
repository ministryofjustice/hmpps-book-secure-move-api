# frozen_string_literal: true

module Api
  module V1
    class MovesController < ApplicationController
      def index
        render json: MoveFinder.new(filter_params).scope
      end

      private

      def filter_params
        params.fetch(:filter, {}).permit(
          :date_from,
          :date_to,
          :from_location_id,
          :location_type,
          :status
        )
      end
    end
  end
end
