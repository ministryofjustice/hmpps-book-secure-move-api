# frozen_string_literal: true

module Api
  module V1
    class MovesController < ApplicationController
      def index
        render json: scope(filter_params)
      end

      private

      # TODO: Refactor into a separate class
      def scope(filter_params)
        filters(Move, filter_params)
      end

      def filters(scope, filter_params)
        scope = scope.where(filter_params.slice(:from_location_id, :to_location_id, :status))
        scope = scope.where('date >= ?', filter_params[:date_from]) if filter_params.key?(:date_from)
        scope = scope.where('date <= ?', filter_params[:date_to]) if filter_params.key?(:date_to)
        if filter_params.key?(:location_type)
          scope =
            scope
            .joins(:to_location)
            .where(locations: { location_type: filter_params[:location_type] })
        end
        scope
      end

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
