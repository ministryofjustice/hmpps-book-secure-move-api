# frozen_string_literal: true

module Allocations
  class Updater
    attr_accessor :allocation_params, :allocation_id, :allocation

    def initialize(allocation_params:, allocation_id:)
      self.allocation_params = allocation_params
      self.allocation_id = allocation_id
    end

    def call
      self.allocation = Allocation.find(allocation_id)
      existing_date = allocation.date

      allocation.assign_attributes(allocation_params[:attributes])
      allocation.validate!

      update_move_dates if allocation.date != existing_date

      allocation.save!
    end

  private

    def update_move_dates
      allocation.transaction do
        allocation.moves.each do |move|
          move.date = allocation.date
          move.save!
        end
      end
    end
  end
end
