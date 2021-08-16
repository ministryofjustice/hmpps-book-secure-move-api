# frozen_string_literal: true

require 'csv'

class Reports::PersonEscortRecordQuality
  def self.call(...)
    new(...).call
  end

  def initialize(start_date:, end_date: nil)
    @start_date = start_date
    @end_date = end_date || Time.zone.now
  end

  private_class_method :new

  def call
    puts csv  # rubocop:disable Rails/Output
  end

private

  attr_reader :start_date, :end_date

  HEADERS = [
    'Move Reference',
    'Started At',
    'Completed At',
    'Last Amended At',
    'Pre-filled',
    'Confirmed At',
    'Handover At',
  ].freeze

  def csv
    CSV.generate(headers: HEADERS, write_headers: true) do |csv|
      records.each do |row|
        csv << row.map { |col| col.respond_to?(:iso8601) ? col.iso8601 : col }
      end
    end
  end

  def records
    @records ||= PersonEscortRecord.joins(:move)
                                   .where(created_at: start_date..end_date)
                                   .order(:created_at)
                                   .pluck(
                                     :"moves.reference",
                                     :created_at,
                                     :completed_at,
                                     :amended_at,
                                     Arel.sql('prefill_source_id IS NOT NULL'),
                                     :confirmed_at,
                                     :handover_occurred_at,
                                   )
  end
end
