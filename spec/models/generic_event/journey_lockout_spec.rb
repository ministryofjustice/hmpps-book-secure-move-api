require 'rails_helper'

RSpec.describe GenericEvent::JourneyLockout do
  subject(:generic_event) { build(:event_journey_lockout) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Journey]) }

  it_behaves_like 'an event with relationships', from_location_id: :locations
  it_behaves_like 'an event requiring a location', :from_location_id
  it_behaves_like 'an event with a location in the feed', :from_location_id

  describe '#from_location' do
    it 'returns a `Location` if from_location_id is in the details' do
      location = create(:location)
      generic_event.details['from_location_id'] = location.id
      expect(generic_event.from_location).to eq(location)
    end

    it 'returns nil if from_location_id is nil in the details' do
      generic_event.details['from_location_id'] = nil
      expect(generic_event.from_location).to be_nil
    end
  end
end
