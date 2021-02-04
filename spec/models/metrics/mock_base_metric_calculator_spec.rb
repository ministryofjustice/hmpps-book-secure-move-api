# frozen_string_literal: true

require 'rails_helper'
require 'csv'

# NB: the mock class name must be unique in test suite
class MockBaseMetricCalculator
  include Metrics::BaseMetric

  def initialize
    setup_metric(
      {
        label: 'label',
        interval: 5.minutes,
        columns: {
          name: 'column',
          field: :itself,
          values: %w[col1 col2],
        },
        rows: {
          name: 'row',
          field: :itself,
          values: %w[row1 row2],
        },
      },
    )
  end

  def calculate(_column, _row)
    1
  end
end

RSpec.describe MockBaseMetricCalculator do
  around do |example|
    Timecop.freeze('2020-10-07 01:02:03')
    example.run
    Timecop.return
  end

  describe 'to_csv' do
    subject(:csv) { CSV.parse(described_class.new.to_csv) }

    it {
      expect(csv).to eql([
        %w[label col1 col2],
        %w[row1 1 1],
        %w[row2 1 1],
      ])
    }
  end

  describe 'to_fixed_key_json' do
    subject(:json) { JSON.parse(described_class.new.to_fixed_key_json) }

    it {
      expect(json).to eql({
        'label' => 'label',
        'timestamp' => '2020-10-07T01:02:03+01:00',
        'data' => [
          { 'row' => 'row1', 'values' => [{ 'column' => 'col1', 'value' => 1 }, { 'column' => 'col2', 'value' => 1 }] },
          { 'row' => 'row2', 'values' => [{ 'column' => 'col1', 'value' => 1 }, { 'column' => 'col2', 'value' => 1 }] },
        ],
      })
    }
  end

  describe 'to_datasette_json' do
    subject(:json) { JSON.parse(described_class.new.to_datasette_json) }

    it {
      expect(json).to eql({
        'database' => 'label',
        'timestamp' => '2020-10-07T01:02:03+01:00',
        'columns' => %w[row col1 col2],
        'rows' => [
          ['row1', 1, 1],
          ['row2', 1, 1],
        ],
      })
    }
  end

  describe 'to_d3_json' do
    subject(:json) { JSON.parse(described_class.new.to_d3_json) }

    it {
      expect(json).to eql({
        'label' => 'label',
        'timestamp' => '2020-10-07T01:02:03+01:00',
        'data' => [
          { 'row' => 'row1', 'col1' => 1, 'col2' => 1 },
          { 'row' => 'row2', 'col1' => 1, 'col2' => 1 },
        ],
      })
    }
  end
end
