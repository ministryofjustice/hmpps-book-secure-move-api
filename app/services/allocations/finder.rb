# frozen_string_literal: true

module Allocations
  class Finder
    attr_reader :filter_params

    def initialize(filter_params)
      @filter_params = filter_params
    end

    def call
      scope = apply_filters(Allocation)
      apply_ordering(scope)
    end

  private

    def apply_ordering(scope)
      scope.order(date: :desc)
    end

    def split_params(name)
      filter_params[name]&.split(',')
    end

    def apply_filters(scope)
      scope = scope.includes(from_location: :suppliers, to_location: :suppliers)
      scope = apply_date_range_filters(scope)
      scope = apply_location_filters(scope)
      scope = apply_status_filters(scope)
      scope
    end

    def apply_date_range_filters(scope)
      scope = scope.where('date >= ?', filter_params[:date_from]) if filter_params.key?(:date_from)
      scope = scope.where('date <= ?', filter_params[:date_to]) if filter_params.key?(:date_to)
      scope
    end

    def apply_location_filters(scope)
      scope = scope.where(from_location_id: split_params(:from_locations)) if filter_params.key?(:from_locations)
      scope = scope.where(to_location_id: split_params(:to_locations)) if filter_params.key?(:to_locations)
      scope = scope.where(from_location_id: split_params(:locations)).or(scope.where(to_location_id: split_params(:locations))) if filter_params.key?(:locations)
      scope
    end

    def apply_status_filters(scope)
      scope = scope.where(status: split_params(:status)) if filter_params.key?(:status)
      scope
    end
  end
end
