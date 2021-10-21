# frozen_string_literal: true

require 'csv'

class Imports::MissingMoveEndingEvents
  include Eventable

  def self.call(...)
    new(...).call
  end

  def initialize(csv_path:, columns:)
    @csv_path = csv_path
    @columns = columns
    @current_move = nil
  end

  private_class_method :new

  def call
    results
  end

private

  attr_reader :csv_path, :columns

  ALLOWED_EVENT_TYPES = %w[MoveCancel MoveReject MoveComplete].freeze
  EXPECTED_MOVE_STATUSES = %i[proposed requested booked in_transit].freeze

  def results
    @results ||= records.each_with_object(Imports::Results.new) do |record, results|
      move = Move.find_by(id: record[:move_id], status: EXPECTED_MOVE_STATUSES)
      if move.nil?
        results.record_failure(record)
        next
      end

      unless ALLOWED_EVENT_TYPES.include?(record[:event_type])
        results.record_failure(record)
        next
      end

      @current_move = move

      process_event(move, "GenericEvent::#{record[:event_type]}".constantize, {
        attributes: {
          timestamp: record[:event_timestamp],
          cancellation_reason: record[:cancellation_reason],
          rejection_reason: record[:rejection_reason],
        },
      })

      @current_move = nil

      results.save(move, record)
    end
  end

  def records
    @records ||= CSV.table(csv_path).map do |record|
      {
        move_id: record[columns.fetch(:move_id)],
        event_type: record[columns.fetch(:event_type)],
        event_timestamp: record[columns.fetch(:event_timestamp)],
        cancellation_reason: record[columns.fetch(:cancellation_reason)],
        rejection_reason: record[columns.fetch(:rejection_reason)],
      }
    end
  end

  def doorkeeper_application_owner
    @current_move&.supplier
  end

  def created_by
    doorkeeper_application_owner&.name
  end
end
