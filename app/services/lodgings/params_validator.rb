# frozen_string_literal: true

module Lodgings
  class ParamsValidator
    include ActiveModel::Validations

    attr_reader :start_date, :end_date

    validate_date = lambda do |record, attr, value|
      Date.iso8601(value)
    rescue ArgumentError
      record.errors.add(attr, 'must be formatted as a valid ISO-8601 date')
    end

    # NB: start_date and end_date are optional on update
    validates_each :start_date, :end_date, allow_nil: true, on: :update, &validate_date
    validates_each :start_date, :end_date, allow_nil: false, unless: -> { validation_context == :update }, &validate_date

    def initialize(params)
      @start_date = params.dig(:attributes, :start_date)
      @end_date = params.dig(:attributes, :end_date)
    end
  end
end
