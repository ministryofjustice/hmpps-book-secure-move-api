# frozen_string_literal: true

module Moves
  class MoveFinder
    attr_accessor :filter_params

    def initialize(filter_params)
      self.filter_params = filter_params
    end

    def call
      apply_filters(Move)
    end

    private

    def apply_filters(scope)
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
  end
end
