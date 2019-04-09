# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Location do
  subject(:location) { described_class.new }

  it { is_expected.to have_many(:moves_from) }
  it { is_expected.to have_many(:moves_to) }
end
