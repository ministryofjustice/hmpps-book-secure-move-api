# frozen_string_literal: true

module JourneyEvents
  class ParamsValidator
    include ActiveModel::Validations

    attr_reader :timestamp, :type

    validates :type, presence: true, inclusion: { in: %w[cancel complete lockouts lodgings start reject uncomplete uncancel] }
    validates_each :timestamp, presence: true do |record, attr, value|
      Time.iso8601(value)
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date-time')
    end

    def initialize(params)
      @timestamp = params.dig(:attributes, :timestamp)
      @type = params[:type]
    end
  end
end
