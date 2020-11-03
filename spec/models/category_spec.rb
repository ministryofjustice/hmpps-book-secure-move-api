# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Category do
  subject(:category) { build(:category) }

  it { is_expected.to have_many(:locations) }
  it { is_expected.to have_many(:profiles) }

  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_uniqueness_of(:key) }
  it { is_expected.to validate_presence_of(:title) }

  # NB: it is not recommended to test that :move_supported is a boolean field - see warning from shoulda-matchers:
  # Be aware that it is not possible to fully test this, as boolean columns will automatically convert non-boolean
  # values to boolean ones.
end
