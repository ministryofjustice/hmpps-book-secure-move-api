require 'csv'

module Metrics
  module Metric
    attr_accessor :label, :interval

    def to_csv
      CSV.generate do |csv|
        csv << [label] + columns.map { |column| column_heading(column) }
        rows.each do |row|
          csv << [row_label(row)] + columns.map { |column| value(row, column) }
        end
      end
    end

    def to_fixed_key_json
      {
        label: label,
        timestamp: Time.zone.now,
        data: rows.map do |row|
          {
            row: row_label(row),
            values: columns.map { |column| { column: column_heading(column), value: value(row, column) } },
          }
        end,
      }
    end
  end
end
