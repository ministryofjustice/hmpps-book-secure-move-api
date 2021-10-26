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
        results.record_failure(record)
        next
      end

      move.status = record[:new_status].downcase
      results.save(move, record)
    end
  end

  def records
    @records ||= CSV.table(csv_path).map do |record|
      {
        move_id: record[columns.fetch(:move_id)],
        old_status: record[columns.fetch(:old_status)],
        new_status: record[columns.fetch(:new_status)],
      }
    end
  end
end
