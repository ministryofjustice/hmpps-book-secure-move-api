# frozen_string_literal: true

module Moves
  class Finder
    attr_reader :filter_params, :ability

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
      case @order_by
      when :name
        scope.joins(person: :profiles).merge(Profile.ordered_by_name(@order_direction))
      when :from_location
        scope.joins(:from_location).merge(Location.ordered_by_title(@order_direction))
      when :to_location
        scope.joins(:to_location).merge(Location.ordered_by_title(@order_direction))
      when :prison_transfer_reason
        scope.left_outer_joins(:prison_transfer_reason).merge(PrisonTransferReason.ordered_by_title(@order_direction))
      when :created_at
        scope.order(created_at: @order_direction)
      when :date_from
        scope.order(date_from: @order_direction)
      when :date
        scope.order(date: @order_direction)
      else
        scope
      end
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
      scope = scope.where('moves.created_at >= ?', filter_params[:created_at_from]) if filter_params.key?(:created_at_from)
      scope = scope.where('moves.created_at <= ?', filter_params[:created_at_to]) if filter_params.key?(:created_at_to)
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
