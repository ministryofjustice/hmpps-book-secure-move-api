# frozen_string_literal: true

require 'csv'

class Imports::DeleteEvents
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
      event = GenericEvent.find_by(id: record[:event_id], eventable_id: record[:eventable_id])
      if event.nil?
        results.record_failure(record, reason: 'Could not find event.')
        next
      end

      event.destroy!
      results.record_success(record)
    end
  end

  def records
    @records ||= column_mapper.map(CSV.table(csv_path))
  end
end
