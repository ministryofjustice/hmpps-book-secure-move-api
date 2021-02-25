require 'rails_helper'

RSpec.describe GenericEvent::MoveLockout do
  subject(:generic_event) { build(:event_move_lockout) }

  let(:reasons) do
    %w[
      unachievable_ptr_request
      no_space
      unachievable_redirection
      late_sitting_court
      unavailable_resource_vehicle_or_staff
      traffic_issues
      mechanical_or_other_vehicle_failure
      ineffective_route_planning
      other
    ]
  end

  it_behaves_like 'an event with details', :authorised_at, :authorised_by, :reason
  it_behaves_like 'an event with relationships', from_location_id: :locations
  it_behaves_like 'a move event'
  it_behaves_like 'an authorised event'
  it_behaves_like 'an event requiring a location', :from_location_id
  it_behaves_like 'an event with a location in the feed', :from_location_id

  it { is_expected.to validate_inclusion_of(:reason).in_array(reasons) }

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
