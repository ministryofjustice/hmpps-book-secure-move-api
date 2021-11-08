# frozen_string_literal: true

require 'csv'

class Imports::MissingJourneyEndingEvents
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

  ALLOWED_JOURNEY_STATES = %w[Completed Cancelled].freeze

  def results
    @results ||= records.each_with_object(Imports::Results.new) do |record, results|
      unless ALLOWED_JOURNEY_STATES.include?(record[:new_state])
        results.record_failure(record, reason: 'New state not allowed.')
        next
      end

      journey = Journey.find_by(id: record[:journey_id], move_id: record[:move_id], state: 'in_progress')
      if journey.nil?
        results.record_failure(record, reason: 'Could not find journey.')
        next
      end

      @current_journey = journey

      process_event(journey, event_name(state: record[:new_state]), {
        attributes: {
          timestamp: record[:event_timestamp],
        },
      })

      @current_journey = nil

      results.save(journey, record)
    end
  end

  def records
    @records ||= column_mapper.map(CSV.table(csv_path))
  end

  def event_name(state:)
    case state
    when 'Cancelled'
      GenericEvent::JourneyCancel
    when 'Rejected'
      GenericEvent::JourneyReject
    when 'Completed'
      GenericEvent::JourneyComplete
    end
  end

  def doorkeeper_application_owner
    @current_journey&.supplier
  end

  def created_by
    doorkeeper_application_owner&.name
  end
end
