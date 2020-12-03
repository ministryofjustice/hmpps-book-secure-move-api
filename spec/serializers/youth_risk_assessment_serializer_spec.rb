# frozen_string_literal: true

require 'rails_helper'

RSpec.describe YouthRiskAssessmentSerializer do
  subject(:serializer) { described_class.new(youth_risk_assessment, include: includes) }

  let(:youth_risk_assessment) { create(:youth_risk_assessment) }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }
  let(:includes) { {} }

  it 'contains a `type` property' do
    expect(result[:data][:type]).to eq('youth_risk_assessments')
  end

  it 'contains a `profile` relationship' do
    expect(result[:data][:relationships][:profile][:data]).to eq(
      id: youth_risk_assessment.profile.id,
      type: 'profiles',
    )
  end

  it 'contains a `move` relationship' do
    expect(result[:data][:relationships][:move][:data]).to eq(
      id: youth_risk_assessment.move.id,
      type: 'moves',
    )
  end

  it 'contains a nil `prefill_source` relationship if no prefill_source present' do
    expect(result[:data][:relationships][:prefill_source][:data]).to be_nil
  end

  context 'with a prefill source' do
    let(:youth_risk_assessment) { create(:youth_risk_assessment, :prefilled) }

    it 'contains a`prefill_source` relationship ' do
      expect(result[:data][:relationships][:prefill_source][:data]).to eq(
        id: youth_risk_assessment.prefill_source.id,
        type: 'youth_risk_assessments',
      )
    end
  end

  context 'with include options' do
    let(:includes) { %w[prefill_source] }
    let(:youth_risk_assessment) do
      create(:youth_risk_assessment, :prefilled)
    end

    let(:expected_json) do
      UnorderedArray(
        {
          id: youth_risk_assessment.prefill_source.id,
          type: 'youth_risk_assessments',
          attributes: { created_at: youth_risk_assessment.prefill_source.created_at.iso8601 },
        },
      )
    end

    it 'contains an included responses and question' do
      expect(result[:included]).to include_json(expected_json)
    end
  end
end
