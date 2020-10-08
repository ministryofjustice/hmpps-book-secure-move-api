require 'csv'

module Metrics
  module BaseMetric
    attr_reader :metric_label, :interval, :timestamp,
                :columns_name, :columns_field, :columns,
                :rows_name, :rows_field, :rows,
                :values

    def setup_metric(metric)
      @metric_label = metric[:label]
      @interval = metric[:interval]
      @timestamp = nil
      @columns_name = metric[:columns][:name]
      @columns_field = metric[:columns][:field]
      @columns = evaluate(metric[:columns][:values])
      @rows_name = metric[:rows][:name]
      @rows_field = metric[:rows][:field]
      @rows = evaluate(metric[:rows][:values])
      @values = nil
    end

    def to_csv
      calculate_all_values
      CSV.generate do |csv|
        csv << [metric_label] + columns.map { |column| column_key(column) }
        rows.each do |row|
          csv << [row_key(row)] + columns.map { |column| value(column, row) }
        end
      end
    end

    def to_fixed_key_json
      calculate_all_values
      {
        label: metric_label,
        timestamp: timestamp.iso8601,
        data: rows.map do |row|
          {
            row: row_key(row),
            values: columns.map { |column| { column: column_key(column), value: value(column, row) } },
          }
        end,
      }
    end

    def to_datasette_json
      calculate_all_values
      {
        database: metric_label,
        timestamp: timestamp.iso8601,
        columns: columns.map { |column| column_key(column) },
        rows: rows.map { |row| columns.map { |column| value(column, row) } },
      }
    end

    def to_d3_json
      calculate_all_values
      {
        label: metric_label,
        timestamp: timestamp.iso8601,
        data: rows.map { |row| ([[rows_name, row_key(row)]] + columns.map { |column| [column_key(column), value(column, row)] }).to_h },
      }
    end

  private

    def evaluate(var)
      if var.is_a?(Proc)
        var.call
      else
        var
      end
    end

    def calculate_all_values
      if values.nil? || timestamp.nil? || timestamp + interval < Time.zone.now
        @values = {}.tap do |v|
          columns.each do |column|
            rows.each do |row|
              v[value_key(column, row)] = calculate(column, row)
            end
          end
        end
        @timestamp = Time.zone.now
      end
    end

    def column_key(column)
      column.present? ? column.send(columns_field) : 'none'
    end

    def row_key(row)
      row.present? ? row.send(rows_field) : 'none'
    end

    def value_key(column, row)
      "#{column_key(column)}__#{row_key(row)}".to_sym
    end

    def value(column, row)
      @values[value_key(column, row)]
    end
  end
end
