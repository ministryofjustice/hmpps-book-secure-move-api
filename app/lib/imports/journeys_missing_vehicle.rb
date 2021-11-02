# frozen_string_literal: true

require 'csv'

class Imports::JourneysMissingVehicle
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
      journey = Journey.find_by(id: record[:journey_id], move_id: record[:move_id])
      if journey.nil?
        results.record_failure(record, reason: 'Could not find journey.')
        next
      end

      journey.vehicle_registration = record[:vehicle_registration]
      results.save(journey, record)
    end
  end

  def records
    @records ||= CSV.table(csv_path).map do |record|
      {
        journey_id: record[columns.fetch(:journey_id)],
        move_id: record[columns.fetch(:move_id)],
        vehicle_registration: record[columns.fetch(:vehicle_registration)],
      }
    end
  end
end
