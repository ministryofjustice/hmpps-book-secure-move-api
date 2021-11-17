# frozen_string_literal: true

require 'csv'

class Imports::JourneysMissingVehicle
  def self.call(...)
    new(...).call
  end

  def initialize(csv_path:, columns:)
    @csv_path = csv_path
    @column_mapper = Imports::ColumnMapper.new(columns)
  end

  private_class_method :new

  def call
    results
  end

private

  attr_reader :csv_path, :column_mapper

  def results
    @results ||= records.each_with_object(Imports::Results.new) do |record, results|
      journey = Journey.find_by(id: record[:journey_id], move_id: record[:move_id])
      if journey.nil?
        results.record_failure(record, reason: 'Could not find journey.')
        next
      end

      next unless results.ensure_valid(journey, record)

      journey.vehicle_registration = record[:vehicle_registration]
      results.save(journey, record)
    end
  end

  def records
    @records ||= column_mapper.map(CSV.table(csv_path))
  end
end
