# frozen_string_literal: true

module Allocations
  class Creator
    attr_accessor :doorkeeper_application_owner, :allocation_params, :complex_case_params, :allocation

    def initialize(doorkeeper_application_owner:, allocation_params:, complex_case_params:)
      self.doorkeeper_application_owner = doorkeeper_application_owner
      self.allocation_params = allocation_params
      self.complex_case_params = complex_case_params
    end

    def call
      self.allocation = Allocation.new(attributes)
      allocation.moves = moves if allocation.valid?

      allocation.save!
    end

  private

    def from_location
      Location.find(allocation_params.dig(:relationships, :from_location, :data, :id))
    end

    def to_location
      Location.find(allocation_params.dig(:relationships, :to_location, :data, :id))
    end

    def moves
      supplier = doorkeeper_application_owner || SupplierChooser.new(allocation).call
      now = Time.zone.now
      created_by = attributes[:requested_by]

      Array.new(allocation.moves_count) do
        Move.new(
          from_location: allocation.from_location,
          to_location: allocation.to_location,
          date: allocation.date,
          supplier:,
          status: Move::MOVE_STATUS_REQUESTED,
        ).tap do |move|
          move.generic_events << GenericEvent::MoveRequested.new(
            occurred_at: now,
            recorded_at: now,
            notes: 'Automatically generated for allocation',
            created_by:,
            supplier: nil,
          )
        end
      end
    end

    def attributes
      allocation_params[:attributes].merge(
        from_location:,
        to_location:,
        complex_cases: Allocation::ComplexCaseAnswers.new(complex_case_params),
      )
    end
  end
end
