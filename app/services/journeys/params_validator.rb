# frozen_string_literal: true

module Journeys
  class ParamsValidator
    include ActiveModel::Validations

    attr_reader :timestamp, :billable, :date

    validates :billable, inclusion: { in: [true, false] }, allow_nil: true, on: :update # NB: billable is optional on update
    validates :billable, inclusion: { in: [true, false] }, on: :create # NB: billable is required on create
    validates_each :timestamp, presence: true do |record, attr, value|
      Time.iso8601(value)
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date-time')
    end
    validates_each :date do |record, attr, value|
      Date.iso8601(value) if value.present?
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date')
    end

    def initialize(params)
      @timestamp = params.dig(:attributes, :timestamp)
      @billable = params.dig(:attributes, :billable)
      @date = params.dig(:attributes, :date)
    end
  end
end
