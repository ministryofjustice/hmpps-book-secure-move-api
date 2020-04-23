# frozen_string_literal: true

module Allocations
  class Finder
    attr_reader :filter_params

    def initialize(filter_params)
      @filter_params = filter_params
    end

    def call
      apply_filters(Allocation)
    end

  private

    def apply_filters(scope)
      scope = scope.includes(from_location: :suppliers, to_location: :suppliers)
      scope = apply_date_range_filters(scope)
      scope
    end

    def apply_date_range_filters(scope)
      scope = scope.where('date >= ?', filter_params[:date_from]) if filter_params.key?(:date_from)
      scope = scope.where('date <= ?', filter_params[:date_to]) if filter_params.key?(:date_to)
      scope
    end
  end
end
