# frozen_string_literal: true

module Allocations
  class ParamsValidator
    include ActiveModel::Validations

    attr_reader :date_from, :date_to

    validates_each :date_from, :date_to, allow_nil: true do |record, attr, value|
      Date.strptime(value, '%Y-%m-%d')
    rescue ArgumentError
      record.errors.add attr, 'is not a valid date.'
    end

    def initialize(filter_params)
      @date_from = filter_params[:date_from]
      @date_to = filter_params[:date_to]
    end
  end
end
