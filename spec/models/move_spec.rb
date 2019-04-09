# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Move do
  subject(:move) { described_class.new }

  it { is_expected.to belong_to(:from_location) }
  it { is_expected.to belong_to(:to_location) }
end
