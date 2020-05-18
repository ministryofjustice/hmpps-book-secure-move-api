# frozen_string_literal: true

module Moves
  class ParamsValidator
    include ActiveModel::Validations

    attr_reader :date_from, :date_to, :created_at_from, :created_at_to, :sort_by, :sort_direction, :move_type, :cancellation_reason

    validates_each :date_from, :date_to, :created_at_from, :created_at_to, allow_nil: true do |record, attr, value|
      Date.strptime(value, '%Y-%m-%d')
    rescue ArgumentError
      record.errors.add attr, 'is not a valid date.'
    end

    validates :move_type, inclusion: { in: Move::move_types }, allow_nil: true
    validates :cancellation_reason, inclusion: { in: Move::CANCELLATION_REASONS }, allow_nil: true
    validates :sort_direction, inclusion: %w[asc desc], allow_nil: true
    validates :sort_by,
              inclusion: %w[name from_location to_location prison_transfer_reason created_at date_from date],
              allow_nil: true
    validates :sort_by, presence: true, unless: -> { sort_direction.nil? }

    def initialize(filter_params, sort_params)
      @date_from = filter_params[:date_from]
      @date_to = filter_params[:date_to]
      @created_at_from = filter_params[:created_at_from]
      @created_at_to = filter_params[:created_at_to]
      @move_type = filter_params[:move_type]
      @cancellation_reason = filter_params[:cancellation_reason]

      @sort_by = sort_params[:by]
      @sort_direction = sort_params[:direction]
    end
  end
end
