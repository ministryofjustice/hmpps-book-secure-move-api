# frozen_string_literal: true

require 'csv'

class Imports::MissingMoveEndingEvents
  include Eventable

  def self.call(...)
    new(...).call
  end

  def initialize(csv_path:, columns:)
    @csv_path = csv_path
    @column_mapper = Imports::ColumnMapper.new(columns)
    @current_move = nil
  end

  private_class_method :new

  def call
    results
  end

private

  attr_reader :csv_path, :column_mapper

  ALLOWED_EVENT_TYPES = %w[MoveCancel MoveReject MoveComplete].freeze
  EXPECTED_MOVE_STATUSES = %i[proposed requested booked in_transit].freeze

  def results
    @results ||= records.each_with_object(Imports::Results.new) do |record, results|
      unless ALLOWED_EVENT_TYPES.include?(record[:event_type])
        results.record_failure(record, reason: 'Event type not allowed.')
        next
      end

      move = Move.find_by(id: record[:move_id], status: EXPECTED_MOVE_STATUSES)
      if move.nil?
        results.record_failure(record, reason: 'Could not find move.')
        next
      end

      next unless results.ensure_valid(move, record)

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
    @records ||= column_mapper.map(CSV.table(csv_path))
  end

  def doorkeeper_application_owner
    @current_move&.supplier
  end

  def created_by
    doorkeeper_application_owner&.name
  end
end
