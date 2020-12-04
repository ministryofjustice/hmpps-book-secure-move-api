# frozen_string_literal: true

module Moves
  class Finder
    attr_reader :filter_params, :ability, :active_record_relationships

    def initialize(filter_params:, ability:, order_params:, active_record_relationships:)
      @filter_params = filter_params
      @ability = ability
      @order_by = (order_params[:by] || 'date').to_sym
      @order_direction = if order_params[:by]
                           (order_params[:direction] || 'asc').to_sym
                         else
                           # default if no 'by' parameter is date descending
                           :desc
                         end
      @active_record_relationships = active_record_relationships
    end

    def call
      scope = apply_filters(Move)
      scope = scope.includes(active_record_relationships)
      apply_ordering(scope)
    end

  private

    def apply_ordering(scope)
      case @order_by
      when :name
        scope.joins(profile: [:person]).merge(Person.ordered_by_name(@order_direction))
      when :from_location
        scope.joins(:from_location).merge(Location.ordered_by_title(@order_direction))
      when :to_location
        scope.joins(:to_location).merge(Location.ordered_by_title(@order_direction))
      when :prison_transfer_reason
        scope.left_outer_joins(:prison_transfer_reason).merge(PrisonTransferReason.ordered_by_title(@order_direction))
      when :created_at, :date_from, :date
        scope.order(@order_by => @order_direction)
      else
        scope
      end
    end

    def apply_filters(scope)
      scope = scope.accessible_by(ability)
      scope = apply_date_range_filters(scope)
      scope = apply_date_of_birth_filters(scope)
      scope = apply_location_type_filters(scope)
      scope = apply_location_filters(scope)
      scope = apply_allocation_relationship_filters(scope)
      scope = apply_ready_for_transit_filters(scope)
      scope = apply_filter(scope, :supplier_id)
      scope = apply_filter(scope, :status)
      scope = apply_filter(scope, :move_type)
      scope = apply_filter(scope, :cancellation_reason)
      scope = apply_filter(scope, :rejection_reason)
      scope
    end

    def split_params(name)
      filter_params[name]&.split(',')
    end

    def apply_filter(scope, param_name)
      if filter_params.key?(param_name)
        scope.where(param_name => split_params(param_name))
      else
        scope
      end
    end

    def apply_date_range_filters(scope)
      scope = scope.where('moves.date >= ?', filter_params[:date_from]) if filter_params.key?(:date_from)
      scope = scope.where('moves.date <= ?', filter_params[:date_to]) if filter_params.key?(:date_to)
      # created_at is a date/time, so inclusive filtering has to be subtly different
      scope = scope.where('moves.created_at >= ?', filter_params[:created_at_from]) if filter_params.key?(:created_at_from)
      scope = scope.where('moves.created_at < ?', Date.parse(filter_params[:created_at_to]) + 1) if filter_params.key?(:created_at_to)
      scope
    end

    def apply_date_of_birth_filters(scope)
      return scope unless filter_params.key?(:date_of_birth_from) || filter_params.key?(:date_of_birth_to)

      # only join on person if necessary, otherwise moves without people are not included
      scope = scope.joins(:person)
      scope = scope.where('people.date_of_birth >= ?', filter_params[:date_of_birth_from]) if filter_params.key?(:date_of_birth_from)
      scope = scope.where('people.date_of_birth <= ?', filter_params[:date_of_birth_to]) if filter_params.key?(:date_of_birth_to)
      scope
    end

    def apply_location_type_filters(scope)
      return scope unless filter_params.key?(:location_type)

      scope
        .joins(:to_location)
        .where(locations: { location_type: filter_params[:location_type] })
    end

    def apply_location_filters(scope)
      scope = scope.where(from_location_id: split_params(:from_location_id)) if filter_params.key?(:from_location_id)
      scope = scope.where(to_location_id: split_params(:to_location_id)) if filter_params.key?(:to_location_id)
      scope = scope.where(from_location_id: split_params(:location_id)).or(scope.where(to_location_id: split_params(:location_id))) if filter_params.key?(:location_id)
      scope
    end

    def apply_allocation_relationship_filters(scope)
      return scope unless filter_params.key?(:has_relationship_to_allocation)

      scope = scope.where.not(allocation_id: nil) if filter_params[:has_relationship_to_allocation] == 'true'
      scope = scope.where(allocation_id: nil) if filter_params[:has_relationship_to_allocation] == 'false'
      scope
    end

    def apply_ready_for_transit_filters(scope)
      return scope unless filter_params.key?(:ready_for_transit) && %w[true false].include?(filter_params[:ready_for_transit])

      scope = scope.joins('LEFT JOIN profiles ON moves.profile_id = profiles.id LEFT JOIN person_escort_records ON person_escort_records.profile_id = profiles.id')
      scope = if filter_params[:ready_for_transit] == 'true'
                scope.where('person_escort_records.status' => 'confirmed')
              else
                scope.where.not('person_escort_records.status' => 'confirmed').or(scope.where('person_escort_records.id' => nil))
              end
      scope
    end
  end
end
