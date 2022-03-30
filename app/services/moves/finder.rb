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

    SIMPLE_FIELD_FILTERS = %i[
      supplier_id
      status
      move_type
      cancellation_reason
      rejection_reason
      profile_id
      reference
    ].freeze

    def apply_filters(scope)
      scope = scope.accessible_by(ability)
      scope = apply_created_at_filters(scope)
      scope = apply_date_of_birth_filters(scope)
      scope = apply_second_degree_filter(scope, :location_type, joins: :to_location, where: :locations)
      scope = apply_allocation_relationship_filters(scope)
      scope = apply_ready_for_transit_filters(scope)
      scope = apply_second_degree_filter(scope, :person_id, joins: :profile, where: :profiles)
      scope = SIMPLE_FIELD_FILTERS.reduce(scope) { |s, filter| apply_filter(s, filter) }
      apply_date_and_location_filters(scope)
    end

    def split_params(name)
      return if filter_params[name].blank?

      filter_params[name].split(',')
    end

    def apply_filter(scope, param_name)
      if filter_params.key?(param_name)
        scope.where(param_name => split_params(param_name))
      else
        scope
      end
    end

    def apply_second_degree_filter(scope, param_name, joins:, where:)
      return scope unless filter_params.key?(param_name)

      scope
        .joins(joins)
        .where(where => { param_name => filter_params[param_name] })
    end

    def apply_created_at_filters(scope)
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

    def apply_date_range_filter(scope)
      if filter_params.key?(:date_from) && filter_params.key?(:date_to)
        scope.where('date BETWEEN ? AND ?', filter_params[:date_from], filter_params[:date_to])
      elsif filter_params.key?(:date_from)
        scope.where('date >= ?', filter_params[:date_from])
      elsif filter_params.key?(:date_to)
        scope.where('date <= ?', filter_params[:date_to])
      else
        scope
      end
    end

    def apply_location_filter(scope)
      scope = scope.where(from_location_id: split_params(:from_location_id)) if filter_params.key?(:from_location_id)
      scope = scope.where(to_location_id: split_params(:to_location_id)) if filter_params.key?(:to_location_id)
      scope = scope.where(from_location_id: split_params(:location_id)).or(scope.where(to_location_id: split_params(:location_id))) if filter_params.key?(:location_id)
      scope
    end

    def multi_date_journey_exists_scope
      Journey
        .not_rejected_or_cancelled
        .where('move_id = moves.id')
        .where.not('date = moves.date')
        .arel.exists
    end

    def apply_move_date_location_filters_scope(scope)
      scope = scope.where.not(multi_date_journey_exists_scope)
      scope = apply_date_range_filter(scope)
      apply_location_filter(scope)
    end

    def apply_journey_date_location_filters_scope(scope)
      journey_scope = Journey.not_rejected_or_cancelled.where('move_id = moves.id')
      journey_scope = apply_date_range_filter(journey_scope)
      journey_scope = apply_location_filter(journey_scope)
      scope.where(multi_date_journey_exists_scope).where(journey_scope.arel.exists)
    end

    def apply_date_and_location_filters(scope)
      should_apply_filter = filter_params.key?(:from_location_id) ||
        filter_params.key?(:to_location_id) ||
        filter_params.key?(:location_id) ||
        filter_params.key?(:date_from) ||
        filter_params.key?(:date_to)

      return scope unless should_apply_filter

      moves_scope = apply_move_date_location_filters_scope(scope)
      journeys_scope = apply_journey_date_location_filters_scope(scope)

      mapped_sql = [moves_scope, journeys_scope].map(&:to_sql).join(') UNION (')
      unionized_sql = "((#{mapped_sql})) moves"

      Move.where(id: Move.from(unionized_sql))
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
      if filter_params[:ready_for_transit] == 'true'
        scope.where('person_escort_records.status' => %w[completed confirmed])
      else
        scope.where.not('person_escort_records.status' => %w[completed confirmed]).or(scope.where('person_escort_records.id' => nil))
      end
    end
  end
end
