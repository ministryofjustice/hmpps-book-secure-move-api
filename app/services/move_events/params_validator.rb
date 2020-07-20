# frozen_string_literal: true

module MoveEvents
  class ParamsValidator
    include ActiveModel::Validations

    # NB: for historical reasons the move events endpoint supports a mixture of plural and singular types (e.g. `complete` and `completes`).
    # Going forwards, types should always be plural to conform to JSON:API. For now, we need to support both: the client should send a
    # `type=completes` but we must accept and process a `type=complete`. This is handled by the singularize_acceptable_plural_types
    # method and the list in ACCEPTABLE_PLURAL_VERBS.
    # TODO: in the future when pluralising types, existing move event records will need updating from singular types to plural types.
    ACCEPTABLE_PLURAL_VERBS = %w[cancels completes approves rejects].freeze

    attr_reader :timestamp, :type, :date, :cancellation_reason, :rejection_reason, :from_location_id, :to_location_id

    validates :type, presence: true, inclusion: { in: %w[accepts approve cancel complete lockouts redirects reject starts] }
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

    validates_with LocationValidator, locations: [:from_location_id], if: -> { type == 'lockouts' }
    validates_with LocationValidator, locations: [:to_location_id], if: -> { type == 'redirects' }

    def initialize(params)
      @timestamp = params.dig(:attributes, :timestamp)
      @type = params[:type]
      @date = params.dig(:attributes, :date)
      @cancellation_reason = params.dig(:attributes, :cancellation_reason)
      @rejection_reason = params.dig(:attributes, :rejection_reason)
      @from_location_id = params.dig(:relationships, :from_location, :data, :id)
      @to_location_id = params.dig(:relationships, :to_location, :data, :id)
      singularize_acceptable_plural_types
    end

  private

    def singularize_acceptable_plural_types
      @type = @type.singularize if ACCEPTABLE_PLURAL_VERBS.include?(@type)
    end
  end
end
