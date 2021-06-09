require 'rails_helper'

RSpec.describe GenericEvent::MoveNotifyPremisesOfExpectedCollectionTime do
  subject(:generic_event) { build(:event_move_notify_premises_of_expected_collection_time) }

  it_behaves_like 'an event with details', :expected_at

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Move]) }
  it { is_expected.to validate_presence_of(:expected_at) }

  it 'is valid when the expected_at value is a valid iso8601 datetime' do
    generic_event.expected_at = '2020-06-16T10:20:30+01:00'
    expect(generic_event).to be_valid
  end

  it 'is invalid when the expected_at value is not a valid iso8601 datetime' do
    generic_event.expected_at = '16-06-2020 10:20:30+01:00'
    expect(generic_event).not_to be_valid
  end
end
