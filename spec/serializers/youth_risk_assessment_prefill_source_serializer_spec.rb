# frozen_string_literal: true

require 'rails_helper'

RSpec.describe YouthRiskAssessmentPrefillSourceSerializer do
  subject(:serializer) { described_class.new(youth_risk_assessment) }

  let(:youth_risk_assessment) { create(:youth_risk_assessment) }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }

  it 'contains a `type` property' do
    expect(result[:data][:type]).to eq('youth_risk_assessments')
  end
end
