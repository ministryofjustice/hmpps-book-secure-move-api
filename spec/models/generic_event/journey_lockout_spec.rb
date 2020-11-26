RSpec.describe GenericEvent::JourneyLockout do
  subject(:generic_event) { build(:event_journey_lockout) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Journey]) }

  it_behaves_like 'an event with relationships', from_location_id: :locations
  it_behaves_like 'an event requiring a location', :from_location_id

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
    subject(:generic_event) { create(:event_journey_lockout, details: { from_location_id: from_location.id }) }

    let(:from_location) { create(:location) }

    let(:expected_json) do
      {
        'id' => generic_event.id,
        'type' => 'JourneyLockout',
        'notes' => 'Flibble',
        'created_at' => be_a(Time),
        'updated_at' => be_a(Time),
        'occurred_at' => be_a(Time),
        'recorded_at' => be_a(Time),
        'eventable_id' => generic_event.eventable_id,
        'eventable_type' => 'Journey',
        'details' => {
          'from_location_type' => from_location.location_type,
          'from_location' => from_location.nomis_agency_id,
        },
      }
    end

    it 'generates a feed document' do
      expect(generic_event.for_feed).to include_json(expected_json)
    end
  end
end
