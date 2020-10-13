# frozen_string_literal: true

module Populations
  class ParamsValidator
    include ActiveModel::Validations

    attr_reader :date_from, :date_to, :sort_by, :sort_direction

    validates :date_from, presence: true
    validates :date_to, presence: true
    validates_each :date_from, :date_to, allow_nil: true do |record, attr, value|
      Date.strptime(value, '%Y-%m-%d')
    rescue ArgumentError
      record.errors.add attr, 'is not a valid date'
    end

    validates :sort_direction, inclusion: %w[asc desc], allow_nil: true
    validates :sort_by, inclusion: %w[title], allow_nil: true

    def initialize(date_params, sort_params)
      @date_from = date_params[:date_from]
      @date_to = date_params[:date_to]

      @sort_by = sort_params[:by]
      @sort_direction = sort_params[:direction]
    end
  end
end
