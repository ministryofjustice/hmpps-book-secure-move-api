# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkFlag do
  subject { create(:framework_flag) }

  it { is_expected.to validate_presence_of(:flag_type) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to belong_to(:framework_question) }
  it { is_expected.to have_and_belong_to_many(:framework_responses) }
  it { is_expected.to validate_inclusion_of(:flag_type).in_array(%w[information attention warning alert]) }
end
