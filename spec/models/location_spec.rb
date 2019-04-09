# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Location do
  it { is_expected.to have_many(:moves_from) }
  it { is_expected.to have_many(:moves_to) }

  it { is_expected.to validate_presence_of(:label) }
  it { is_expected.to validate_presence_of(:location_type) }
end
