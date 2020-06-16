# frozen_string_literal: true

module MoveEvents
  class ParamsValidator
    include ActiveModel::Validations

    ACCEPTABLE_PLURAL_VERBS = %w[cancels completes approves rejects].freeze

    attr_reader :timestamp, :type, :date, :cancellation_reason, :rejection_reason

    validates :type, presence: true, inclusion: { in: %w[cancel complete lockouts redirects approve reject] }
    validates :cancellation_reason, inclusion: { in: Move::CANCELLATION_REASONS }, if: -> { type == 'cancel' }
    validates :rejection_reason, inclusion: { in: Move::REJECTION_REASONS }, if: -> { type == 'reject' }

    validates :date, presence: true, if: -> { type == 'approve' }
    validates :timestamp, presence: true

    validates_each :date, allow_nil: true do |record, attr, value|
      Date.strptime(value, '%Y-%m-%d')
    rescue ArgumentError
      record.errors.add attr, 'is not a valid date.'
    end

    validates_each :timestamp, allow_nil: true do |record, attr, value|
      Time.iso8601(value)
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date-time')
    end

    def initialize(params)
      @timestamp = params.dig(:attributes, :timestamp)
      @type = params[:type]
      @date = params.dig(:attributes, :date)
      @cancellation_reason = params.dig(:attributes, :cancellation_reason)
      @rejection_reason = params.dig(:attributes, :rejection_reason)

      singularize_acceptable_plural_types
    end

  private

    def singularize_acceptable_plural_types
      @type = @type.singularize if ACCEPTABLE_PLURAL_VERBS.include?(@type)
    end
  end
end
