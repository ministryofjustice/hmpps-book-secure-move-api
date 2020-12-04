# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::Moves::CountsByMoveTypeStatus do
  subject(:metric) { described_class.new }

  it 'includes the BaseMetric module' do
    expect(described_class.ancestors).to include(Metrics::BaseMetric)
  end

  it 'initializes label' do
    expect(metric.label).to eql(described_class::METRIC[:label])
  end

  describe 'calculate' do
    let(:supplier1) { create(:supplier) }
    let(:supplier2) { create(:supplier) }

    before do
      create(:move, :proposed, :prison_recall)
      create(:move, :requested, :prison_recall)
      create(:move, :requested, :prison_transfer)
      create(:move, :completed, :hospital)
    end

    it 'computes the metric' do
      expect(metric.calculate(:prison_recall, :proposed)).to be(1)
      expect(metric.calculate(:hospital, :requested)).to be(0)
    end
  end
end
