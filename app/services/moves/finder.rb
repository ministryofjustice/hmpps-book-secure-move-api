# frozen_string_literal: true

module Moves
  class Finder
    attr_accessor :filter_params

    def initialize(filter_params)
      self.filter_params = filter_params
    end

    def call
      apply_filters(Move).order('moves.id')
    end

    private

    def apply_filters(scope)
      scope = scope.includes(:from_location, :to_location, profile: %i[gender ethnicity])
      scope = scope.where(filter_params.slice(:status))
      scope = apply_date_range_filters(scope)
      scope = apply_location_type_filters(scope)
      scope = apply_location_from_filters(scope)
      scope = apply_location_to_filters(scope)
      scope = apply_supplier_filters(scope)
      scope
    end

    def apply_date_range_filters(scope)
      scope = scope.where('date >= ?', filter_params[:date_from]) if filter_params.key?(:date_from)
      scope = scope.where('date <= ?', filter_params[:date_to]) if filter_params.key?(:date_to)
      scope
    end

    def apply_location_type_filters(scope)
      return scope unless filter_params.key?(:location_type)

      scope
        .joins(:to_location)
        .where(locations: { location_type: filter_params[:location_type] })
    end

    def apply_location_from_filters(scope)
      return scope unless filter_params.key?(:from_location_id)

      from_location = filter_params[:from_location_id].split(',')
      scope.where(from_location_id: from_location)
    end

    def apply_location_to_filters(scope)
      return scope unless filter_params.key?(:to_location_id)

      to_location = filter_params[:to_location_id].split(',')
      scope.where(to_location_id: to_location)
    end

    def apply_supplier_filters(scope)
      return scope unless filter_params.key?(:supplier_id)

      scope.served_by(filter_params[:supplier_id])
    end
  end
end
