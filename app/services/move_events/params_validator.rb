# frozen_string_literal: true

module MoveEvents
  class ParamsValidator
    include ActiveModel::Validations

    attr_reader :timestamp, :type, :cancellation_reason

    validates :type, presence: true, inclusion: { in: %w[cancel complete lockouts redirects events] } # TODO: remove 'events' type once FE updated
    validates :cancellation_reason, inclusion: { in: Move::CANCELLATION_REASONS }, if: -> { type == 'cancel' }
    validates_each :timestamp, presence: true do |record, attr, value|
      Time.iso8601(value)
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date-time')
    end

    def initialize(params)
      @timestamp = params.dig(:attributes, :timestamp)
      @type = params[:type]
      @cancellation_reason = params.dig(:attributes, :cancellation_reason)
    end
  end
end
