# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Flag do
  subject { create(:flag) }

  it { is_expected.to validate_presence_of(:flag_type) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to belong_to(:framework_question) }
  it { is_expected.to have_and_belong_to_many(:framework_responses) }
  it { is_expected.to validate_inclusion_of(:flag_type).in_array(%w[information attention warning alert]) }
end
