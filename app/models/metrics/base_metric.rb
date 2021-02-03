require 'csv'
require 'json'

module Metrics
  module BaseMetric
    TOTAL = 'total'.freeze
    COUNT = 'count'.freeze
    MOVES = 'moves'.freeze

    attr_reader :supplier, :label, :database, :file, :interval, :timestamp,
                :columns_name, :columns_field, :columns,
                :rows_name, :rows_field, :rows,
                :values

    FORMATS = {
      to_csv: 'data.csv',
      to_fixed_key_json: 'data-fixed_key.json',
      to_datasette_json: 'data-datasette.json',
      to_d3_json: 'data-d3.json',
    }.freeze

    def setup_metric(metric)
      @supplier = metric[:supplier]
      @label = build_label(metric[:label], metric[:supplier])
      @database = metric[:database]
      @file = build_file(metric[:file], metric[:supplier])
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
        csv << [label] + columns.map { |column| column_key(column) }
        rows.each do |row|
          csv << [row_key(row)] + columns.map { |column| value(column, row) }
        end
      end
    end

    def to_fixed_key_json
      calculate_all_values
      JSON.pretty_generate({
        label: label,
        timestamp: timestamp.iso8601,
        data: rows.map do |row|
          {
            row: row_key(row),
            values: columns.map { |column| { column: column_key(column), value: value(column, row) } },
          }
        end,
      })
    end

    def to_datasette_json
      calculate_all_values
      JSON.pretty_generate({
        database: label,
        timestamp: timestamp.iso8601,
        columns: [rows_name] + columns.map { |column| column_key(column) },
        rows: rows.map { |row| [row_key(row)] + columns.map { |column| value(column, row) } },
      })
    end

    def to_d3_json
      calculate_all_values
      JSON.pretty_generate({
        label: label,
        timestamp: timestamp.iso8601,
        data: rows.map { |row| ([[rows_name, row_key(row)]] + columns.map { |column| [column_key(column), value(column, row)] }).to_h },
      })
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
        if respond_to?(:calculate_table)
          @values = calculate_table
          pause
        else
          @values = {}.tap do |v|
            rows.each do |row|
              if respond_to?(:calculate_row)
                # do calculation a row at a time
                row_values = ActiveSupport::HashWithIndifferentAccess.new(calculate_row(row))
                row_values.default = 0
                columns.each do |column|
                  v[value_key(column, row)] = row_values[column]
                end
                # sleep for a very short while to avoid overloading the system
                pause
              else
                # do calculation a cell at a time
                columns.each do |column|
                  v[value_key(column, row)] = calculate(column, row)
                  # sleep for a very short while to avoid overloading the system
                  pause
                end
              end
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

    def build_label(label, supplier)
      if supplier.present?
        "#{label} (#{supplier.key})"
      else
        label
      end
    end

    def build_file(file, supplier)
      if supplier.present?
        "#{file}-#{supplier.key}"
      else
        file
      end
    end

    def pause
      sleep(rand(0..0.1).round(2))
    end
  end
end
