# frozen_string_literal: true

module JourneyEvents
  class ParamsValidator
    include ActiveModel::Validations

    attr_reader :timestamp, :type, :from_location_id, :to_location_id

    validates :type, presence: true, inclusion: { in: %w[cancels completes lockouts lodgings starts rejects uncompletes uncancels] }
    validates_each :timestamp, presence: true do |record, attr, value|
      Time.iso8601(value)
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date-time')
    end
    validates_with LocationValidator, locations: [:from_location_id], if: -> { type == 'lockouts' }
    validates_with LocationValidator, locations: [:to_location_id], if: -> { type == 'lodgings' }

    def initialize(params)
      @timestamp = params.dig(:attributes, :timestamp)
      @type = params[:type]
      @from_location_id = params.dig(:relationships, :from_location, :data, :id)
      @to_location_id = params.dig(:relationships, :to_location, :data, :id)
    end
  end
end
