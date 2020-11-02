# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Category do
  subject(:category) { build(:category) }

  it { is_expected.to have_many(:locations) }
  it { is_expected.to have_many(:profiles) }

  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_uniqueness_of(:key) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_inclusion_of(:move_supported).in_array([true, false]) }
end
