# frozen_string_literal: true

module Allocations
  class ParamsValidator
    include ActiveModel::Validations

    attr_reader :date_from, :date_to, :locations, :from_locations, :to_locations, :sort_by, :sort_direction

    validates_each :date_from, :date_to, allow_nil: true do |record, attr, value|
      Date.strptime(value, '%Y-%m-%d')
    rescue ArgumentError
      record.errors.add attr, 'is not a valid date.'
    end

    validates_each :locations, allow_blank: true do |record, attr, _value|
      record.errors.add attr, 'may not be used in combination with `from_locations` or `to_locations` filters.' if record.from_locations.present? || record.to_locations.present?
    end

    validates :sort_direction, inclusion: %w[asc desc], allow_nil: true
    validates :sort_by,
              inclusion: %w[from_location to_location moves_count date],
              allow_nil: true

    def initialize(filter_params, sort_params)
      @date_from = filter_params[:date_from]
      @date_to = filter_params[:date_to]
      @locations = filter_params[:locations]
      @from_locations = filter_params[:from_locations]
      @to_locations = filter_params[:to_locations]

      @sort_by = sort_params[:by]
      @sort_direction = sort_params[:direction]
    end
  end
end
