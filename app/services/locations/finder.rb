# frozen_string_literal: true

module Locations
  class Finder
    attr_accessor :filter_params

    def initialize(filter_params)
      self.filter_params = filter_params
    end

    def call
      apply_filters(Location)
    end

    private

    def apply_filters(scope)
      scope = scope.includes(:suppliers)
      scope = scope.where(filter_params.slice(:location_type, :nomis_agency_id))
      scope = apply_supplier_filters(scope)
      scope
    end

    def apply_supplier_filters(scope)
      return scope unless filter_params.key?(:supplier_id)

      scope.joins(:locations_suppliers).where(suppliers: { id: filter_params[:supplier_id] })
    end
  end
end
