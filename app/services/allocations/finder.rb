# frozen_string_literal: true

module Allocations
  class Finder
    attr_reader :filter_params, :search_params, :active_record_relationships

    def initialize(filters: {}, ordering: {}, search: {}, active_record_relationships: [])
      @search_params = search
      @filter_params = filters
      @order_by = (ordering[:by] || 'date').to_sym
      @order_direction = if ordering[:by]
                           (ordering[:direction] || 'asc').to_sym
                         else
                           # default if no 'by' parameter is date descending
                           :desc
                         end
      @active_record_relationships = active_record_relationships
    end

    def call
      scope = Allocation.includes(active_record_relationships)
      scope = apply_filters(scope)
      scope = apply_search(scope)
      apply_ordering(scope)
    end

  private

    def apply_ordering(scope)
      case @order_by
      when :from_location
        scope.joins(:from_location).merge(Location.ordered_by_title(@order_direction))
      when :to_location
        scope.joins(:to_location).merge(Location.ordered_by_title(@order_direction))
      when :moves_count, :date
        scope.order(@order_by => @order_direction)
      else
        scope
      end
    end

    def apply_search(scope)
      scope = apply_location_search(scope)
      apply_person_search(scope)
    end

    def apply_location_search(scope)
      return scope unless (search = search_params[:location].presence)

      scope.where(from_location_id: Location.search_by_title(search)).or(
        scope.where(to_location_id: Location.search_by_title(search)),
      )
    end

    def apply_person_search(scope)
      return scope unless (search = search_params[:person].presence)

      scope.includes(moves: { profile: :person }).where('people.id' => Person.search_by_last_name(search))
    end

    def apply_filters(scope)
      scope = apply_date_range_filters(scope)
      scope = apply_location_filters(scope)
      apply_status_filters(scope)
    end

    def apply_date_range_filters(scope)
      scope = scope.where('allocations.date >= ?', filter_params[:date_from]) if filter_params.key?(:date_from)
      scope = scope.where('allocations.date <= ?', filter_params[:date_to]) if filter_params.key?(:date_to)
      scope
    end

    def split_params(name)
      return if filter_params[name].blank?

      filter_params[name].split(',')
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
