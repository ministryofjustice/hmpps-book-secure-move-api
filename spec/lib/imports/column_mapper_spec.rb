# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Imports::ColumnMapper do
  subject(:mapped_rows) { described_class.new(columns).map(rows) }

  let(:columns) do
    {
      a: :b,
      c: { source: :d, downcase: true },
    }
  end

  let(:rows) do
    [
      { b: 'B', d: 'D' },
    ]
  end

  it { is_expected.to eq([{ a: 'B', c: 'd' }]) }
end
