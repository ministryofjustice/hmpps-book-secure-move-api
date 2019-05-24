# frozen_string_literal: true

module Moves
  class MoveFinder
    attr_accessor :filter_params

    def initialize(filter_params)
      self.filter_params = filter_params
    end

    def call
      apply_filters(Move).order('locations.description')
    end

    private

    def apply_filters(scope)
      scope = scope.where(filter_params.slice(:from_location_id, :to_location_id, :status))
      scope = apply_date_range_filters(scope)
      scope = apply_location_type_filters(scope)
      scope
    end

    def apply_date_range_filters(scope)
      scope = scope.where('date >= ?', filter_params[:date_from]) if filter_params.key?(:date_from)
      scope = scope.where('date <= ?', filter_params[:date_to]) if filter_params.key?(:date_to)
      scope
    end

    def apply_location_type_filters(scope)
      scope = scope.joins(:to_location)
      return scope unless filter_params.key?(:location_type)

      scope
        .where(locations: { location_type: filter_params[:location_type] })
    end
  end
end
