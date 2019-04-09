# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Move do
  it { is_expected.to belong_to(:from_location) }
  it { is_expected.to belong_to(:to_location) }
  it { is_expected.to belong_to(:person) }

  it { is_expected.to validate_presence_of(:from_location) }
  it { is_expected.to validate_presence_of(:to_location) }
  it { is_expected.to validate_presence_of(:person) }
  it { is_expected.to validate_presence_of(:date) }
  it { is_expected.to validate_presence_of(:time_due) }
  it { is_expected.to validate_presence_of(:move_type) }
  it { is_expected.to validate_presence_of(:status) }
end
