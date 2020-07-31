# frozen_string_literal: true

module Moves
  class Finder
    attr_reader :filter_params, :ability

    MOVE_INCLUDES = [:court_hearings, :prison_transfer_reason, :original_move, :from_location, :to_location, profile: [:documents, person_escort_record: [:framework, :framework_responses, framework_flags: :framework_question]], person: %i[gender ethnicity], from_location: %i[locations_suppliers suppliers], to_location: %i[locations_suppliers suppliers], allocation: %i[to_location from_location]].freeze

    def initialize(filter_params, ability, order_params)
      @filter_params = filter_params
      @ability = ability
      @order_by = (order_params[:by] || 'date').to_sym
      @order_direction = if order_params[:by]
                           (order_params[:direction] || 'asc').to_sym
                         else
                           # default if no 'by' parameter is date descending
                           :desc
                         end
    end

    def call
      scope = apply_filters(Move)
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
      scope = scope.includes(MOVE_INCLUDES)
      scope = apply_date_range_filters(scope)
      scope = apply_location_type_filters(scope)
      scope = apply_allocation_relationship_filters(scope)
      scope = apply_ready_for_transit_filters(scope)
      scope = apply_filter(scope, :supplier_id)
      scope = apply_filter(scope, :from_location_id)
      scope = apply_filter(scope, :to_location_id)
      scope = apply_filter(scope, :status)
      scope = apply_filter(scope, :move_type)
      scope = apply_filter(scope, :cancellation_reason)
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
      # created_at is a date/time, so inclusive filtering has to be subtlely different
      scope = scope.where('moves.created_at >= ?', filter_params[:created_at_from]) if filter_params.key?(:created_at_from)
      scope = scope.where('moves.created_at < ?', Date.parse(filter_params[:created_at_to]) + 1) if filter_params.key?(:created_at_to)
      scope
    end

    def apply_location_type_filters(scope)
      return scope unless filter_params.key?(:location_type)

      scope
        .joins(:to_location)
        .where(locations: { location_type: filter_params[:location_type] })
    end

    def apply_allocation_relationship_filters(scope)
      return scope unless filter_params.key?(:has_relationship_to_allocation)

      scope = scope.where.not(allocation_id: nil) if filter_params[:has_relationship_to_allocation] == 'true'
      scope = scope.where(allocation_id: nil) if filter_params[:has_relationship_to_allocation] == 'false'
      scope
    end

    def apply_ready_for_transit_filters(scope)
      return scope unless filter_params.key?(:ready_for_transit)

      scope = scope.where('person_escort_records.status' => 'confirmed') if filter_params[:ready_for_transit] == 'true'
      scope = scope.where.not('person_escort_records.status' => 'confirmed').or(scope.where('person_escort_records.id' => nil)) if filter_params[:ready_for_transit] == 'false'

      scope
    end
  end
end
