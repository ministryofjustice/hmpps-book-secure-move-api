# frozen_string_literal: true

require 'rails_helper'

RSpec.describe YouthRiskAssessmentsSerializer do
  subject(:serializer) { described_class.new(youth_risk_assessment) }

  let(:youth_risk_assessment) { create(:youth_risk_assessment) }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }
  let(:expected_result) do
    {
      data: {
        id: youth_risk_assessment.id,
        type: 'youth_risk_assessments',
        attributes: {
          status: 'not_started',
        },
      },
    }
  end

  it 'contains the expected data' do
    expect(result).to eq(expected_result)
  end
end
