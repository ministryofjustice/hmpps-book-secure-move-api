# frozen_string_literal: true

require 'rails_helper'
require 'csv'

# NB: the mock class name must be unique in test suite
class MockBaseMetric
  include Metrics::BaseMetric

  def initialize
    setup_metric(
      {
        label: 'label',
        interval: 5.minutes,
        columns: {
          name: 'column',
          field: :itself,
          values: ['col', nil],
        },
        rows: {
          name: 'row',
          field: :itself,
          values: ['row', nil],
        },
      },
    )
  end

  def calculate(_column, _row)
    0
  end
end

RSpec.describe MockBaseMetric do
  around do |example|
    Timecop.freeze('2020-10-07 01:02:03')
    example.run
    Timecop.return
  end

  describe 'to_csv' do
    subject(:csv) { CSV.parse(described_class.new.to_csv) }

    it {
      expect(csv).to eql([
        %w[label col none],
        %w[row 0 0],
        %w[none 0 0],
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
          { 'row' => 'row', 'values' => [{ 'column' => 'col', 'value' => 0 }, { 'column' => 'none', 'value' => 0 }] },
          { 'row' => 'none', 'values' => [{ 'column' => 'col', 'value' => 0 }, { 'column' => 'none', 'value' => 0 }] },
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
        'columns' => %w[col none],
        'rows' => [
          [0, 0],
          [0, 0],
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
          { 'row' => 'row', 'col' => 0, 'none' => 0 },
          { 'row' => 'none', 'col' => 0, 'none' => 0 },
        ],
      })
    }
  end
end
