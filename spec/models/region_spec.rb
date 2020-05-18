# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Region do
  subject(:region) { build(:region) }

  it { is_expected.to have_and_belong_to_many(:locations) }

  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_presence_of(:name) }

  it { is_expected.to validate_uniqueness_of(:key) }
  it { is_expected.to validate_uniqueness_of(:name) }
end
