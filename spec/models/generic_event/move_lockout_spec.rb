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

  it { is_expected.to validate_presence_of(:from_location_id) }
  it { is_expected.to validate_inclusion_of(:reason).in_array(reasons) }

  context 'when authorised_at is supplied' do
    it 'is valid when the authorised_at value is a valid iso8601 datetime' do
      generic_event.authorised_at = '2020-06-16T10:20:30+01:00'
      expect(generic_event).to be_valid
    end

    it 'is invalid when the authorised_at value is not a valid iso8601 datetime' do
      generic_event.authorised_at = '16-06-2020 10:20:30+01:00'
      expect(generic_event).not_to be_valid
    end
  end

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
    subject(:generic_event) { create(:event_move_lockout, details: { from_location_id: from_location.id, reason: 'no_space', authorised_at: Time.zone.now.iso8601, authorised_by: 'Joe Bloggs' }) }

    let(:from_location) { create(:location) }

    let(:expected_json) do
      {
        'id' => generic_event.id,
        'type' => 'GenericEvent::MoveLockout',
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
          'authorised_by' => 'Joe Bloggs',
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
