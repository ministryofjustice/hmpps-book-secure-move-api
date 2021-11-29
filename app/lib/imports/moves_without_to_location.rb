# frozen_string_literal: true

require 'csv'

class Imports::MovesWithoutToLocation
  def self.call(...)
    new(...).call
  end

  def initialize(csv_path:, columns:)
    @csv_path = csv_path
    @column_mapper = Imports::ColumnMapper.new({
      move_id: columns.fetch(:move_id),
      location_key: { source: columns.fetch(:location_key), downcase: true },
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
      move = Move.find_by(id: record[:move_id])
      if move.nil?
        results.record_failure(record, reason: 'Could not find move.')
        next
      end

      next unless results.ensure_valid(move, record)

      location = Location.find_by(key: record[:location_key])
      if location.nil?
        results.record_failure(record, reason: 'Could not find location.')
        next
      end

      move.to_location = location

      results.save(move, record)
    end
  end

  def records
    @records ||= column_mapper.map(CSV.table(csv_path))
  end
end
