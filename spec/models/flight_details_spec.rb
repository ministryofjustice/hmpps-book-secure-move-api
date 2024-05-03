# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FlightDetails do
  subject(:flight_details) { build(:flight_details, flight_time:) }

  let(:flight_time) { '2024-01-01T12:00:00Z' }

  it { is_expected.to belong_to(:move) }

  it { is_expected.to validate_presence_of(:flight_number) }
  it { is_expected.to validate_presence_of(:flight_time) }

  context 'when the flight_time format is not an iso8601 date' do
    let(:flight_time) { '2024/01/01' }

    it { is_expected.to be_invalid }
  end
end
