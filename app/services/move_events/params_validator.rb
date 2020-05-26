# frozen_string_literal: true

module MoveEvents
  class ParamsValidator
    include ActiveModel::Validations

    attr_reader :timestamp, :type

    validates :type, presence: true, inclusion: { in: %w[complete redirects] }
    validates_each :timestamp, presence: true do |record, attr, value|
      Time.iso8601(value)
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date-time')
    end

    def initialize(params)
      @timestamp = params.dig(:attributes, :timestamp)
      @type = params.dig(:type)
    end
  end
end
