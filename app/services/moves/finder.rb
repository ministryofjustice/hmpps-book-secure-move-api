# frozen_string_literal: true

module Moves
  class Finder
    attr_accessor :filter_params, :ability

    def initialize(filter_params, ability = nil)
      self.filter_params = filter_params
      self.ability = ability
    end

    def call
      apply_filters(Move).order('moves.id')
    end

  private

    def apply_filters(scope)
      scope = scope.accessible_by(ability)
      scope = scope.includes(:from_location, :to_location, person: { profiles: %i[gender ethnicity] })
      scope = apply_filter(scope, :status)
      scope = apply_date_range_filters(scope)
      scope = apply_location_type_filters(scope)
      scope = apply_filter(scope, :from_location_id)
      scope = apply_filter(scope, :to_location_id)
      scope = apply_supplier_filters(scope)
      scope
    end

    def apply_filter(scope, param_name)
      if filter_params.key?(param_name)
        scope.where(param_name => filter_params[param_name].split(','))
      else
        scope
      end
    end

    def apply_date_range_filters(scope)
      scope = scope.where('date >= ?', filter_params[:date_from]) if filter_params.key?(:date_from)
      scope = scope.where('date <= ?', filter_params[:date_to]) if filter_params.key?(:date_to)
      scope = scope.where('created_at >= ?', filter_params[:created_at_from]) if filter_params.key?(:created_at_from)
      scope = scope.where('created_at <= ?', filter_params[:created_at_to]) if filter_params.key?(:created_at_to)
      scope
    end

    def apply_location_type_filters(scope)
      return scope unless filter_params.key?(:location_type)

      scope
        .joins(:to_location)
        .where(locations: { location_type: filter_params[:location_type] })
    end

    def apply_supplier_filters(scope)
      return scope unless filter_params.key?(:supplier_id)

      scope.served_by(filter_params[:supplier_id])
    end
  end
end
