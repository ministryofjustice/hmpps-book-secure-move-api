# frozen_string_literal: true

module Moves
  class ParamsValidator
    include ActiveModel::Validations

    attr_reader :date_from, :date_to, :created_at_from, :created_at_to, :date_of_birth_from, :date_of_birth_to, :sort_by, :sort_direction, :move_type, :status, :cancellation_reason, :rejection_reason

    validates_each :date_from, :date_to, :created_at_from, :created_at_to, :date_of_birth_from, :date_of_birth_to, allow_nil: true do |record, attr, value|
      Date.strptime(value, '%Y-%m-%d')
    rescue ArgumentError
      record.errors.add attr, 'is not a valid date.'
    end

    validates_each :cancellation_reason, :rejection_reason, allow_nil: true do |record, attr, value|
      values = value&.split(',') || []
      if (values - Move.const_get(attr.to_s.pluralize.upcase)).any?
        record.errors.add(attr, :inclusion)
      end
    end

    validates :move_type, inclusion: { in: Move.move_types }, allow_nil: true
    validates :status, inclusion: { in: Move.statuses }, allow_nil: true

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
      @date_of_birth_from = filter_params[:date_of_birth_from]
      @date_of_birth_to = filter_params[:date_of_birth_to]
      @move_type = filter_params[:move_type]
      @status = filter_params[:status]
      @cancellation_reason = filter_params[:cancellation_reason]
      @rejection_reason = filter_params[:rejection_reason]

      @sort_by = sort_params[:by]
      @sort_direction = sort_params[:direction]
    end
  end
end
