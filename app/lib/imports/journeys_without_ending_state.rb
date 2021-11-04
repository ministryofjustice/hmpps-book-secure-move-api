# frozen_string_literal: true

require 'csv'

class Imports::JourneysWithoutEndingState
  def self.call(...)
    new(...).call
  end

  def initialize(csv_path:, columns:)
    @csv_path = csv_path
    @column_mapper = Imports::ColumnMapper.new({
      journey_id: columns.fetch(:journey_id),
      move_id: columns.fetch(:move_id),
      old_state: { source: columns.fetch(:old_state), downcase: true },
      new_state: { source: columns.fetch(:new_state), downcase: true },
    })
  end

  private_class_method :new

  def call
    results
  end

private

  attr_reader :csv_path, :column_mapper

  def results
    @results ||= records.each_with_object(Imports::Results.new) do |record, results|
      journey = Journey.find_by(id: record[:journey_id], move_id: record[:move_id], state: record[:old_state])
      if journey.nil?
        results.record_failure(record, reason: 'Could not find journey.')
        next
      end

      new_state = record[:new_state]

      event = find_event(journey, new_state)
      if event.nil?
        results.record_failure(record, reason: 'Could not find associated event.')
        next
      end

      journey.state_machine.restore!(find_pre_trigger_state(new_state)) # to ensure event state transition is valid
      event.eventable = journey  # to ensure we are modifying the same object

      event.trigger(dry_run: true)

      if journey.state != new_state
        results.record_failure(record, reason: 'Event did not trigger state change.')
        next
      end

      results.save(journey, record)
    end
  end

  def find_event(journey, new_state)
    case new_state
    when 'cancelled'
      GenericEvent::JourneyCancel.find_by(eventable: journey)
    when 'rejected'
      GenericEvent::JourneyReject.find_by(eventable: journey)
    when 'completed'
      GenericEvent::JourneyComplete.find_by(eventable: journey)
    end
  end

  def find_pre_trigger_state(new_state)
    case new_state
    when 'rejected'
      :proposed
    else
      :in_progress
    end
  end

  def records
    @records ||= column_mapper.map(CSV.table(csv_path))
  end
end
