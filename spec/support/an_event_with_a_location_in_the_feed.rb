# frozen_string_literal: true

RSpec.shared_examples 'an event with a location in the feed' do |location_id_key|
  describe '#for_feed' do
    before do
      generic_event.details[location_id_key] = location.id
    end

    let(:location) { create(:location) }

    let(:expected_json) do
      location_key = location_id_key.to_s.sub('_id', '')
      location_type_key = "#{location_key}_type"

      {
        'id' => generic_event.id,
        'type' => generic_event.type.sub('GenericEvent::', ''),
        'notes' => 'Flibble',
        'eventable_id' => generic_event.eventable_id,
        'eventable_type' => generic_event.eventable_type,
        'details' => {
          location_key => location.nomis_agency_id,
          location_type_key => location.location_type,
        },
      }
    end

    it 'generates a feed document' do
      expect(generic_event.for_feed).to include_json(expected_json)
    end
  end
end
