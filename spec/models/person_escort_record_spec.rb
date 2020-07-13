# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonEscortRecord do
  it { is_expected.to validate_presence_of(:state) }
  it { is_expected.to validate_inclusion_of(:state).in_array(%w[in_progress completed confirmed]) }
  it { is_expected.to have_many(:framework_responses) }
  it { is_expected.to belong_to(:framework) }
  it { is_expected.to belong_to(:profile) }
end
