# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkNomisMapping do
  subject { create(:framework_nomis_mapping) }

  it { is_expected.to validate_presence_of(:raw_nomis_mapping) }
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_presence_of(:code_type) }
  it { is_expected.to validate_inclusion_of(:code_type).in_array(%w[alert assessment contact personal_care_need reasonable_adjustment]) }
  it { is_expected.to have_and_belong_to_many(:framework_responses) }
end
