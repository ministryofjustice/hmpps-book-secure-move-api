# frozen_string_literal: true

module Locations
  class Finder
    attr_accessor :filter_params, :order_by, :order_direction, :active_record_relationships

    def initialize(filter_params:, sort_params: {}, active_record_relationships: [])
      self.filter_params = filter_params
      self.order_by = (sort_params[:by] || 'title').to_sym
      self.order_direction = (sort_params[:direction] || 'asc').to_sym
      self.active_record_relationships = active_record_relationships
    end

    def call
      scope = Location.includes(active_record_relationships)
      scope = apply_filters(scope)
      apply_ordering(scope)
    end

  private

    def apply_ordering(scope)
      case order_by
      when :title
        scope.order(title: order_direction)
      when :category
        scope.left_joins(:category).order('categories.title' => order_direction, 'locations.title' => order_direction)
      else
        scope
      end
    end

    def apply_filters(scope)
      scope = apply_location_type_filters(scope)
      scope = apply_nomis_agency_filters(scope)
      scope = apply_supplier_filters(scope)
      scope = apply_location_filters(scope)
      scope = apply_region_filters(scope)
      scope = apply_young_offender_institution_filters(scope)
      scope = apply_extradition_filters(scope)
      apply_created_at_filters(scope)
    end

    def split_params(name)
      return if filter_params[name].blank?

      filter_params[name].split(',')
    end

    def apply_location_type_filters(scope)
      scope = scope.where(location_type: split_params(:location_type)) if filter_params.key?(:location_type)
      scope
    end

    def apply_nomis_agency_filters(scope)
      scope = scope.where(nomis_agency_id: split_params(:nomis_agency_id)) if filter_params.key?(:nomis_agency_id)
      scope
    end

    def apply_supplier_filters(scope)
      scope = scope.includes(:suppliers)

      return scope unless filter_params.key?(:supplier_id)

      scope = scope.includes(:suppliers).where(suppliers: { id: split_params(:supplier_id) })
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

    def apply_young_offender_institution_filters(scope)
      scope = scope.where(young_offender_institution: true) if filter_params[:young_offender_institution].to_s == 'true'
      scope = scope.where(young_offender_institution: false) if filter_params[:young_offender_institution].to_s == 'false'
      scope
    end

    def apply_extradition_filters(scope)
      scope = scope.where(extradition_capable: true) if filter_params.key?(:extradition_capable)
      scope
    end

    def apply_created_at_filters(scope)
      return scope if filter_params[:created_at].blank?

      date = Date.strptime(filter_params[:created_at], '%Y-%m-%d')
      scope.where(created_at: date.midnight..date.end_of_day)
    end
  end
end
