# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkNomisCode do
  subject { create(:framework_nomis_code) }

  it { is_expected.to have_and_belong_to_many(:framework_questions) }
  it { is_expected.to validate_presence_of(:code_type) }
  it { is_expected.to validate_inclusion_of(:code_type).in_array(%w[alert assessment contact personal_care_need reasonable_adjustment]) }

  context 'when fallback false' do
    it { is_expected.to validate_presence_of(:code) }
  end

  context 'when fallback true' do
    subject { create(:framework_nomis_code, fallback: true) }

    it { is_expected.not_to validate_presence_of(:code) }
  end
end
