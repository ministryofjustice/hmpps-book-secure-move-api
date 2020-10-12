# frozen_string_literal: true

module Locations
  class Finder
    attr_accessor :filter_params, :order_by, :order_direction

    def initialize(filter_params, sort_params = {})
      self.filter_params = filter_params
      self.order_by = (sort_params[:by] || 'title').to_sym
      self.order_direction = (sort_params[:direction] || 'asc').to_sym
    end

    def call
      scope = apply_filters(Location)
      apply_ordering(scope)
    end

  private

    def apply_ordering(scope)
      case @order_by
      when :title
        scope.order(@order_by => @order_direction)
      else
        scope
      end
    end

    def apply_filters(scope)
      scope = scope.includes(:suppliers)
      scope = scope.where(filter_params.slice(:location_type, :nomis_agency_id))
      scope = apply_supplier_filters(scope)
      scope = apply_location_filters(scope)
      scope = apply_region_filters(scope)
      scope
    end

    def split_params(name)
      filter_params[name]&.split(',')
    end

    def apply_supplier_filters(scope)
      return scope unless filter_params.key?(:supplier_id)

      scope = scope.where(suppliers: { id: split_params(:supplier_id) })
      scope.merge(SupplierLocation.effective_on(Time.zone.today))
    end

    def apply_location_filters(scope)
      scope = scope.where(id: split_params(:location_id)) if filter_params.key?(:location_id)
      scope
    end

    def apply_region_filters(scope)
      scope = scope.joins(:regions).where(regions: { id: split_params(:region_id) }) if filter_params.key?(:region_id)
      scope
    end
  end
end
