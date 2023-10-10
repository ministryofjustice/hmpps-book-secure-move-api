# frozen_string_literal: true

require 'rails_helper'

RSpec.describe YouthRiskAssessment do
  let(:from_location) { create(:location, :stc) }

  it { is_expected.to belong_to(:move) }

  context 'with validations' do
    it 'is valid if the move from location is from an stc' do
      location = create(:location, :stc)
      move = create(:move, from_location: location)
      youth_risk_assessment = build(:youth_risk_assessment, move:)

      expect(youth_risk_assessment).to be_valid
    end

    it 'is valid if the move from location is from an sch' do
      location = create(:location, :sch)
      move = create(:move, from_location: location)
      youth_risk_assessment = build(:youth_risk_assessment, move:)

      expect(youth_risk_assessment).to be_valid
    end

    it 'is valid if the move from location is a youth offender institution' do
      location = create(:location, young_offender_institution: true)
      move = create(:move, from_location: location)
      youth_risk_assessment = build(:youth_risk_assessment, move:)

      expect(youth_risk_assessment).to be_valid
    end

    it 'is invalid if the move from location is not from an sch or stc or youth offender institution' do
      location = create(:location, :prison, young_offender_institution: false)
      move = create(:move, from_location: location)
      youth_risk_assessment = build(:youth_risk_assessment, move:)

      expect(youth_risk_assessment).not_to be_valid
      expect(youth_risk_assessment.errors.messages[:move]).to eq(["'from_location' must be from either a secure training centre or a secure children's home"])
    end

    it 'is invalid if there is no move attached to a youth risk assessment' do
      youth_risk_assessment = build(:youth_risk_assessment, move: nil)

      expect(youth_risk_assessment).not_to be_valid
      expect(youth_risk_assessment.errors.messages[:move]).to eq(['must exist', "'from_location' must be from either a secure training centre or a secure children's home"])
    end
  end

  it_behaves_like 'a framework assessment', :youth_risk_assessment, described_class
end
