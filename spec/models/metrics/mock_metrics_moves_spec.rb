# frozen_string_literal: true

require 'rails_helper'

# NB: the mock class name must be unique in test suite
class MockMetricsMoves
  include Metrics::Moves

  attr_reader :supplier

  def initialize(supplier: nil)
    @supplier = supplier
  end
end

RSpec.describe MockMetricsMoves do
  context 'without supplier' do
    describe 'database' do
      subject { described_class.new.database }

      it { is_expected.to eql('moves') }
    end

    describe 'moves' do
      subject { described_class.new.moves }

      let(:moves) { create_list(:move, 2) }

      before do
        moves
      end

      it { is_expected.to match_array(moves) }
    end
  end

  context 'with supplier' do
    let(:supplier) { create(:supplier, key: 'supplier') }

    describe 'database' do
      subject { described_class.new(supplier: supplier).database }

      it { is_expected.to eql('moves_supplier') }
    end

    describe 'moves' do
      subject { described_class.new(supplier: supplier).moves }

      let(:moves) { create_list(:move, 2, supplier: supplier) }
      let(:other_moves) { create_list(:move, 2) }

      before do
        moves
        other_moves
      end

      it { is_expected.to match_array(moves) }
    end
  end
end
