# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenericEvent::MoveDateChanged do
  subject(:generic_event) { build(:event_move_date_changed) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Move]) }
  it { is_expected.to validate_presence_of(:date) }

  it 'is valid when the expected_at value is a valid iso8601 date' do
    generic_event.date = '2020-06-16'
    expect(generic_event).to be_valid
  end

  it 'is invalid when the expected_at value is not a valid iso8601 date' do
    generic_event.date = '16-06-2020'
    expect(generic_event).not_to be_valid
  end
end
