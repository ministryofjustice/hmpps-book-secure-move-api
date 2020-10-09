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

  it_behaves_like 'a move event'
  it_behaves_like 'an authorised event'
  it_behaves_like 'an event requiring a location', :from_location_id

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

  describe '#for_feed' do
    subject(:generic_event) { create(:event_move_lockout, details: { from_location_id: from_location.id, reason: 'no_space', authorised_at: Time.zone.now.iso8601, authorised_by: 'CDM' }) }

    let(:from_location) { create(:location) }

    let(:expected_json) do
      {
        'id' => generic_event.id,
        'type' => 'MoveLockout',
        'notes' => 'Flibble',
        'created_at' => be_a(Time),
        'updated_at' => be_a(Time),
        'occurred_at' => be_a(Time),
        'recorded_at' => be_a(Time),
        'eventable_id' => generic_event.eventable_id,
        'eventable_type' => 'Move',
        'details' => {
          'from_location_type' => from_location.location_type,
          'from_location' => from_location.nomis_agency_id,
          'reason' => 'no_space',
          'authorised_at' => generic_event.authorised_at,
          'authorised_by' => 'CDM',
        },
      }
    end

    it 'generates a feed document' do
      expect(generic_event.for_feed).to include_json(expected_json)
    end
  end

  describe '.from_event' do
    let(:move) { create(:move) }

    let(:event) do
      create(:event, :lockout, eventable: move,
                               details: {
                                 event_params: {
                                   attributes: {
                                     notes: 'notes',
                                   },
                                   relationships: {
                                     from_location: { data: { id: move.from_location.id } },
                                   },
                                 },
                               })
    end

    let(:expected_generic_event_attributes) do
      {
        'id' => nil,
        'eventable_id' => move.id,
        'eventable_type' => 'Move',
        'type' => 'GenericEvent::MoveLockout',
        'notes' => 'notes',
        'details' => {
          'from_location_id' => move.from_location.id,
        },
        'created_by' => 'unknown',
        'occurred_at' => eq(event.client_timestamp),
        'recorded_at' => eq(event.client_timestamp),
        'created_at' => be_within(0.1.seconds).of(event.created_at),
        'updated_at' => be_within(0.1.seconds).of(event.updated_at),
      }
    end

    it 'builds a generic_event with the correct attributes' do
      expect(
        described_class.from_event(event).attributes,
      ).to include_json(expected_generic_event_attributes)
    end
  end
end
