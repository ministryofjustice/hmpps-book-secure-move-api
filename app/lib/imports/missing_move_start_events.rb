# frozen_string_literal: true

require 'csv'

class Imports::MissingMoveStartEvents
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

  def results
    @results ||= records.each_with_object(Imports::Results.new) do |record, results|
      move = Move.find_by(id: record[:move_id])
      if move.nil?
        results.record_failure(record, reason: 'Could not find move.')
        next
      end

      @current_move = move

      process_event(move, GenericEvent::MoveStart, {
        attributes: {
          timestamp: record[:event_timestamp],
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
        event_timestamp: record[columns.fetch(:event_timestamp)],
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
