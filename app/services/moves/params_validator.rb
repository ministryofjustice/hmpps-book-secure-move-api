# frozen_string_literal: true

module Moves
  class ParamsValidator
    include ActiveModel::Validations

    attr_accessor :date_from, :date_to

    validates_each :date_from, :date_to, allow_nil: true do |record, attr, value|
      Date.strptime(value, '%Y-%m-%d')
    rescue ArgumentError
      record.errors.add attr, 'is not a valid date.'
    end

    def initialize(params = {})
      return unless params

      @date_from = params[:date_from]
      @date_to = params[:date_to]
    end
  end
end
