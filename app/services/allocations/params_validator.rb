# frozen_string_literal: true

module Allocations
  class ParamsValidator
    include ActiveModel::Validations

    attr_reader :date_from, :date_to, :locations, :from_locations, :to_locations

    validates_each :date_from, :date_to, allow_nil: true do |record, attr, value|
      Date.strptime(value, '%Y-%m-%d')
    rescue ArgumentError
      record.errors.add attr, 'is not a valid date.'
    end

    validates_each :locations, allow_blank: true do |record, attr, _value|
      record.errors.add attr, 'may not be used in combination with `from_locations` or `to_locations` filters.' if record.from_locations.present? || record.to_locations.present?
    end

    def initialize(filter_params)
      @date_from = filter_params[:date_from]
      @date_to = filter_params[:date_to]
      @locations = filter_params[:locations]
      @from_locations = filter_params[:from_locations]
      @to_locations = filter_params[:to_locations]
    end
  end
end
