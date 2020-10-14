RSpec.describe GenericEvent::JourneyLodging do
  subject(:generic_event) { build(:event_journey_lodging) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Journey]) }

  it_behaves_like 'an event with relationships', :to_location_id
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

  describe '.from_event' do
    let(:journey) { create(:journey) }

    context 'when the event has locations' do
      let(:event) { create(:event, :cancel, :locations, eventable: journey) }
      let(:expected_generic_event_attributes) do
        {
          'id' => nil,
          'eventable_id' => journey.id,
          'eventable_type' => 'Journey',
          'type' => 'GenericEvent::JourneyLodging',
          'notes' => 'foo',
          'created_by' => 'unknown',
          'details' => { 'to_location_id' => match(uuid_regex) },
          'occurred_at' => eq(event.client_timestamp),
          'recorded_at' => eq(event.client_timestamp),
          'created_at' => be_within(0.1.seconds).of(event.created_at),
          'updated_at' => be_within(0.1.seconds).of(event.updated_at),
        }
      end

      it 'builds a generic_event with the correct attributes' do
        expect(described_class.from_event(event).attributes).to include_json(expected_generic_event_attributes)
      end

      it 'builds a valid generic_event' do
        expect(described_class.from_event(event)).to be_valid
      end
    end
  end
end
