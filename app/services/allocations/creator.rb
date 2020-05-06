# frozen_string_literal: true

module Allocations
  class Creator
    attr_accessor :allocation_params, :complex_case_params, :allocation

    def initialize(allocation_params:, complex_case_params:)
      self.allocation_params = allocation_params
      self.complex_case_params = complex_case_params
    end

    def call
      self.allocation = Allocation.new(attributes)

      allocation.save!
    end

  private

    def date
      @date ||= allocation_params.dig(:attributes, :date)
    end

    def from_location
      @from_location ||= Location.find(allocation_params.dig(:relationships, :from_location, :data, :id))
    end

    def to_location
      @to_location ||= Location.find(allocation_params.dig(:relationships, :to_location, :data, :id))
    end

    def moves
      return [] unless date

      Array.new(allocation_params.dig(:attributes, :moves_count)) {
        Move.new(
          from_location: from_location,
          to_location: to_location,
          date: date,
        )
      }
    end

    def attributes
      allocation_params[:attributes].merge(
        from_location: from_location,
        to_location: to_location,
        complex_cases: Allocation::ComplexCaseAnswers.new(complex_case_params),
        moves: moves,
      )
    end
  end
end
