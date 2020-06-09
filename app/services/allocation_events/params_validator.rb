# frozen_string_literal: true

module AllocationEvents
  class ParamsValidator
    include ActiveModel::Validations

    # TODO: remove event_name when allocation `events` endpoint is no longer in use
    attr_reader :event_name, :timestamp

    validates :event_name, inclusion: %w[cancel], allow_nil: true
    validates_each :timestamp, presence: true do |record, attr, value|
      Time.iso8601(value)
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date-time')
    end

    def initialize(params)
      @event_name = params.dig(:attributes, :event_name)
      @timestamp = params.dig(:attributes, :timestamp)
    end
  end
end
