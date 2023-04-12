# frozen_string_literal: true

module Allocations
  class Updater
    include Eventable

    attr_accessor :allocation_params, :allocation_id, :allocation, :created_by, :doorkeeper_application_owner

    def initialize(allocation_params:, allocation_id:, doorkeeper_application_owner:, created_by:)
      self.allocation_params = allocation_params
      self.allocation_id = allocation_id
      self.doorkeeper_application_owner = doorkeeper_application_owner
      self.created_by = created_by
    end

    def call
      self.allocation = Allocation.find(allocation_id)
      existing_date = allocation.date

      allocation.assign_attributes(allocation_params[:attributes])
      allocation.validate!

      allocation.transaction do
        update_move_dates if allocation.date != existing_date
        allocation.save!
      end
    end

  private

    def update_move_dates
      allocation.moves.each do |move|
        move.date = allocation.date
        move.save!

        create_automatic_event!(
          eventable: move,
          event_class: GenericEvent::MoveDateChanged,
          details: { date: move.date.iso8601 },
        )

        Notifier.prepare_notifications(topic: move, action_name: 'update')
      end
    end
  end
end
