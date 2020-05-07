# frozen_string_literal: true

module Journeys
  class ParamsValidator
    include ActiveModel::Validations

    attr_reader :action_name, :timestamp, :billable, :vehicle, :from_location_id, :to_location_id

    validates :billable, inclusion: { in: [true, false] }, allow_nil: :update?
    validates :from_location_id, presence: true, if: :create? # NB: locations are only specified on create
    validates :to_location_id, presence: true, if: :create?   # NB: locations are only specified on create
    validates_each :timestamp, presence: true do |record, attr, value|
      Time.iso8601(value)
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date-time')
    end

    def initialize(params, action_name)
      params.require(:data).tap do |data_params|
        @timestamp = data_params.dig(:attributes, :timestamp)
        @billable = data_params.dig(:attributes, :billable)
        @vehicle = data_params.dig(:attributes, :vehicle)
        @from_location_id = data_params.dig(:relationships, :from_location, :data, :id)
        @to_location_id = data_params.dig(:relationships, :to_location, :data, :id)
      end
      @action_name = action_name
    end

    def create?
      action_name == 'create'
    end

    def update?
      action_name == 'update'
    end
  end
end
