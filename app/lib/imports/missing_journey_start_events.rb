# frozen_string_literal: true

require 'csv'

class Imports::MissingJourneyStartEvents
  include Eventable

  def self.call(...)
    new(...).call
  end

  def initialize(csv_path:, columns:)
    @csv_path = csv_path
    @column_mapper = Imports::ColumnMapper.new(columns)
    @current_journey = nil
  end

  private_class_method :new

  def call
    results
  end

private

  attr_reader :csv_path, :column_mapper

  def results
    @results ||= records.each_with_object(Imports::Results.new) do |record, results|
      journey = Journey.find_by(id: record[:journey_id])
      if journey.nil?
        results.record_failure(record, reason: 'Could not find journey.')
        next
      end

      next unless results.ensure_valid(journey, record)

      @current_journey = journey

      process_event(journey, GenericEvent::JourneyStart, {
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

  def doorkeeper_application_owner
    @current_journey&.supplier
  end

  def created_by
    doorkeeper_application_owner&.name
  end
end
