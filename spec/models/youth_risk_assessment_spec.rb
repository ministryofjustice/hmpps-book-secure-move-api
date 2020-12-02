# frozen_string_literal: true

require 'rails_helper'

RSpec.describe YouthRiskAssessment do
  it { is_expected.to belong_to(:move) }

  it_behaves_like 'a framework assessment', :youth_risk_assessment, described_class
end
