# frozen_string_literal: true

module Journeys
  class ParamsValidator
    include ActiveModel::Validations

    attr_reader :action_name, :timestamp, :billable, :vehicle, :from_location_id, :to_location_id

    validates :billable, inclusion: { in: [true, false] }, allow_nil: true, on: :update # NB: billable is optional on update
    validates :billable, inclusion: { in: [true, false] }, on: :create # NB: billable is required on create
    validates :from_location_id, presence: true, on: :create # NB: locations are only specified on create
    validates :to_location_id, presence: true, on: :create   # NB: locations are only specified on create
    validates_each :timestamp, presence: true do |record, attr, value|
      Time.iso8601(value)
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date-time')
    end

    def initialize(params)
      @timestamp = params.dig(:attributes, :timestamp)
      @billable = params.dig(:attributes, :billable)
      @vehicle = params.dig(:attributes, :vehicle)
      @from_location_id = params.dig(:relationships, :from_location, :data, :id)
      @to_location_id = params.dig(:relationships, :to_location, :data, :id)
    end
  end
end
