# frozen_string_literal: true

module Events
  class CommonParamsValidator
    EVENT_CLASSES = %w[
      MoveCancelV2
    ].freeze

    include ActiveModel::Validations

    attr_reader :client_timestamp, :event_type

    validates :client_timestamp, presence: true
    validates_each :client_timestamp do |record, attr, value|
      Time.zone.iso8601(value)
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date-time')
    end

    validates :event_type, presence: true, inclusion: { in: EVENT_CLASSES }

    def initialize(event_params)
      @client_timestamp = event_params.dig('attributes', 'client_timestamp')
      @event_type = event_params.dig('attributes', 'event_type')
    end
  end
end
