# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Journey, type: :model do
  it { is_expected.to belong_to(:move) }
  it { is_expected.to belong_to(:supplier) }
  it { is_expected.to belong_to(:from_location) }
  it { is_expected.to belong_to(:to_location) }

  it { is_expected.to validate_presence_of(:move) }
  it { is_expected.to validate_presence_of(:supplier) }
  it { is_expected.to validate_presence_of(:from_location) }
  it { is_expected.to validate_presence_of(:to_location) }
  it { is_expected.to validate_presence_of(:client_timestamp) }

  it { is_expected.to validate_exclusion_of(:billable).in_array([nil]) }
  it { is_expected.to validate_exclusion_of(:completed).in_array([nil]) }
  it { is_expected.to validate_exclusion_of(:cancelled).in_array([nil]) }
end
