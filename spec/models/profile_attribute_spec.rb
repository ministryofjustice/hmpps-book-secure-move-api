# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProfileAttribute do
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_presence_of(:profile_attribute_type) }
  it { is_expected.to validate_presence_of(:profile) }

  it { is_expected.to belong_to(:profile) }
  it { is_expected.to belong_to(:profile_attribute_type) }
end
