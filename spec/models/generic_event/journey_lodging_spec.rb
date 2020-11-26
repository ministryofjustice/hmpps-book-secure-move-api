RSpec.describe GenericEvent::JourneyLodging do
  subject(:generic_event) { build(:event_journey_lodging) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Journey]) }

  it_behaves_like 'an event with relationships', to_location_id: :locations
  it_behaves_like 'an event requiring a location', :to_location_id

  describe '#to_location' do
    it 'returns a `Location` if to_location_id is in the details' do
      location = create(:location)
      generic_event.details['to_location_id'] = location.id
      expect(generic_event.to_location).to eq(location)
    end

    it 'returns nil if to_location_id is nil in the details' do
      generic_event.details['to_location_id'] = nil
      expect(generic_event.to_location).to be_nil
    end
  end

  describe '#for_feed' do
    subject(:generic_event) { create(:event_journey_lodging, details: { to_location_id: to_location.id }) }

    let(:to_location) { create(:location) }

    let(:expected_json) do
      {
        'id' => generic_event.id,
        'type' => 'JourneyLodging',
        'notes' => 'Flibble',
        'created_at' => be_a(Time),
        'updated_at' => be_a(Time),
        'occurred_at' => be_a(Time),
        'recorded_at' => be_a(Time),
        'eventable_id' => generic_event.eventable_id,
        'eventable_type' => 'Journey',
        'details' => {
          'to_location_type' => to_location.location_type,
          'to_location' => to_location.nomis_agency_id,
        },
      }
    end

    it 'generates a feed document' do
      expect(generic_event.for_feed).to include_json(expected_json)
    end
  end
end
