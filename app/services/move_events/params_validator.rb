# frozen_string_literal: true

module MoveEvents
  class ParamsValidator
    include ActiveModel::Validations

    attr_reader :event_name, :timestamp, :notes

    validates :event_name, inclusion: %w[redirect], presence: true
    validates_each :timestamp, presence: true do |record, attr, value|
      Time.iso8601(value)
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date-time, e.g. 2020-04-29T22:45:59.000Z')
    end

    def initialize(params)
      @event_name = params.dig(:attributes, :event_name)
      @timestamp = params.dig(:attributes, :timestamp)
      @notes = params.dig(:attributes, :notes)
    end
  end
end
