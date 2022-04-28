# frozen_string_literal: true

RSpec.shared_examples 'an event with a location in the feed' do |location_id_key|
  describe '#for_feed' do
    subject(:for_feed) { generic_event.for_feed }

    before { generic_event.details[location_id_key] = location&.id }

    let(:location_key) { location_id_key.to_s.sub('_id', '') }
    let(:location_type_key) { "#{location_key}_type" }

    let(:common_expected_json) do
      {
        'id' => generic_event.id,
        'type' => generic_event.type.sub('GenericEvent::', ''),
        'notes' => 'Flibble',
        'eventable_id' => generic_event.eventable_id,
        'eventable_type' => generic_event.eventable_type,
      }
    end

    context 'when location is present' do
      let(:location) { create(:location) }

      let(:expected_json) do
        common_expected_json.merge({
          'details' => {
            location_key => location.nomis_agency_id,
            location_type_key => location.location_type,
          },
        })
      end

      it { is_expected.to include_json(expected_json) }
    end

    context 'when location is nil' do
      let(:location) { nil }

      let(:expected_json) do
        common_expected_json.merge({
          'details' => { location_key => nil },
        })
      end

      it { is_expected.to include_json(expected_json) }
    end
  end
end
