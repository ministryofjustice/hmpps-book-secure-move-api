# frozen_string_literal: true

module People
  class ParamsValidator
    include ActiveModel::Validations

    attr_reader :date_from, :date_to

    validates_each :date_from, :date_to, allow_nil: false do |record, attr, value|
      Date.iso8601(value)
    rescue ArgumentError
      record.errors.add attr, 'is not a valid iso8601 date.'
    end

    def initialize(filter_params)
      @date_from = filter_params[:date_from]
      @date_to = filter_params[:date_to]
    end
  end
end
