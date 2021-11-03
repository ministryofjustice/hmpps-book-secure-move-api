# frozen_string_literal: true

require 'csv'

class Imports::MovesWithoutEndingState
  def self.call(...)
    new(...).call
  end

  def initialize(csv_path:, columns:)
    @csv_path = csv_path
    @columns = columns
  end

  private_class_method :new

  def call
    results
  end

private

  attr_reader :csv_path, :columns

  def results
    @results ||= records.each_with_object(Imports::Results.new) do |record, results|
      move = Move.find_by(id: record[:move_id], status: record[:old_status])
      if move.nil?
        results.record_failure(record, reason: 'Could not find move.')
        next
      end

      new_status = record[:new_status]

      event = find_event(move, new_status)
      if event.nil?
        results.record_failure(record, reason: 'Could not find associated event.')
        next
      end

      move.state_machine.restore!(find_pre_trigger_status(new_status)) # to ensure event state transition is valid
      event.eventable = move  # to ensure we are modifying the same object

      event.trigger(dry_run: true)

      if move.status != find_expected_status(new_status)
        results.record_failure(record, reason: 'Event did not trigger state change.')
        next
      end

      results.save(move, record)
    end
  end

  def find_event(move, new_status)
    case new_status
    when 'cancelled'
      GenericEvent::MoveCancel.find_by(eventable: move)
    when 'rejected'
      GenericEvent::MoveReject.find_by(eventable: move)
    when 'completed'
      GenericEvent::MoveComplete.find_by(eventable: move)
    end
  end

  def find_pre_trigger_status(new_status)
    case new_status
    when 'rejected'
      :requested
    else
      :in_transit
    end
  end

  def find_expected_status(new_status)
    case new_status
    when 'completed'
      'completed'
    else
      'cancelled'
    end
  end

  def records
    @records ||= CSV.table(csv_path).map do |record|
      {
        move_id: record[columns.fetch(:move_id)],
        old_status: record[columns.fetch(:old_status)].downcase,
        new_status: record[columns.fetch(:new_status)].downcase,
      }
    end
  end
end
