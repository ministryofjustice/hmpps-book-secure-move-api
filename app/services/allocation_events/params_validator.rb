# frozen_string_literal: true

module AllocationEvents
  class ParamsValidator
    include ActiveModel::Validations

    attr_reader :event_name, :timestamp

    validates :event_name, inclusion: %w[cancel], presence: true
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
