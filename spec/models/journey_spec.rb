# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Journey, type: :model do
  subject(:journey) { create(:journey) }

  it { is_expected.to belong_to(:move) }
  it { is_expected.to belong_to(:supplier) }
  it { is_expected.to belong_to(:from_location) }
  it { is_expected.to belong_to(:to_location) }

  it { is_expected.to validate_presence_of(:move) }
  it { is_expected.to validate_presence_of(:supplier) }
  it { is_expected.to validate_presence_of(:from_location) }
  it { is_expected.to validate_presence_of(:to_location) }
  it { is_expected.to validate_presence_of(:client_timestamp) }
  it { is_expected.to validate_presence_of(:state) }
  it { is_expected.to validate_exclusion_of(:billable).in_array([nil]) }
  it { is_expected.to validate_inclusion_of(:state).in_array(%w(in_progress completed cancelled)) }

  describe 'state' do
    subject(:state) { journey.state }

    context 'when default' do
      it { is_expected.to eql 'in_progress' }
    end

    context 'when the journey is cancelled' do
      before { journey.cancel }

      it { is_expected.to eql 'cancelled' }
    end

    context 'when the journey is completed' do
      before { journey.complete }

      it { is_expected.to eql 'completed' }
    end
  end
end
