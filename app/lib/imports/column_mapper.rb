class Imports::ColumnMapper
  Column = Struct.new(:source_key, :target_key, :downcase?) do
    def fetch(row)
      value = row.fetch(source_key)
      return value&.downcase if downcase?

      value
    end
  end

  def initialize(columns)
    @columns = columns.map do |target_key, value|
      downcase = value.is_a?(Symbol) ? false : value.fetch(:downcase)
      source_key = value.is_a?(Symbol) ? value : value.fetch(:source)
      Column.new(source_key, target_key, downcase)
    end
  end

  attr_reader :columns

  def map(rows)
    rows.map do |row|
      columns.each_with_object({}) do |column, memo|
        memo[column.target_key] = column.fetch(row)
      end
    end
  end
end
