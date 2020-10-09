RSpec.describe GenericEvent::MoveRedirect do
  subject(:generic_event) { build(:event_move_redirect) }

  let(:redirect_reasons) do
    %w[
      no_space
      serious_incident
      covid
      receiving_prison_request
      force_majeure
      other
    ]
  end

  it_behaves_like 'a move event'

  it_behaves_like 'an event requiring a location', :to_location_id

  it { is_expected.to validate_inclusion_of(:reason).in_array(redirect_reasons) }

  context 'when reason is nil' do
    before do
      generic_event.details.delete('reason')
    end

    it { is_expected.to be_valid }
  end

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

  describe '#trigger' do
    subject(:generic_event) { build(:event_move_redirect, details: details, eventable: eventable) }

    let(:details) { { move_type: 'court_appearance' } }

    let(:to_location) { create(:location) }
    let(:eventable) { build(:move, move_type: 'prison_transfer') }

    it 'does not persist changes to the eventable' do
      generic_event.trigger

      expect(generic_event.eventable).not_to be_persisted
    end

    it 'sets the eventable `to_location` to the to_location' do
      expect { generic_event.trigger }.to change { generic_event.eventable.to_location }.to(generic_event.to_location)
    end

    context 'when a move_type is included in the details' do
      let(:details) do
        {
          move_type: 'court_appearance',
          to_location_id: to_location.id,
        }
      end

      it 'sets the eventable `move_type' do
        expect { generic_event.trigger }.to change { generic_event.eventable.move_type }.from('prison_transfer').to('court_appearance')
      end
    end
  end

  describe '#for_feed' do
    subject(:generic_event) { create(:event_move_redirect, details: details) }

    let(:to_location) { create(:location) }

    context 'when the move_type is present' do
      let(:details) do
        {
          to_location_id: to_location.id,
          move_type: 'court_appearance',
        }
      end
      let(:expected_json) do
        {
          'id' => generic_event.id,
          'type' => 'MoveRedirect',
          'notes' => 'Flibble',
          'created_at' => be_a(Time),
          'updated_at' => be_a(Time),
          'occurred_at' => be_a(Time),
          'recorded_at' => be_a(Time),
          'eventable_id' => generic_event.eventable_id,
          'eventable_type' => 'Move',
          'details' => {
            'to_location_type' => to_location.location_type,
            'to_location' => to_location.nomis_agency_id,
            'move_type' => 'court_appearance',
          },
        }
      end

      it 'generates a feed document' do
        expect(generic_event.for_feed).to include_json(expected_json)
      end
    end

    context 'when the move_type is absent' do
      let(:details) do
        {
          to_location_id: to_location.id,
        }
      end
      let(:expected_json) do
        {
          'id' => generic_event.id,
          'type' => 'MoveRedirect',
          'notes' => 'Flibble',
          'created_at' => be_a(Time),
          'updated_at' => be_a(Time),
          'occurred_at' => be_a(Time),
          'recorded_at' => be_a(Time),
          'eventable_id' => generic_event.eventable_id,
          'eventable_type' => 'Move',
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
      let(:move) { create(:move) }
      let(:new_location) { create(:location) }
      let(:event) do
        create(:event, :redirect, :locations, eventable: move,
                                              details: {
                                                event_params: {
                                                  attributes: {
                                                    notes: 'foo',
                                                    move_type: 'prison_transfer',
                                                  },
                                                  relationships: {
                                                    to_location: { data: { id: move.from_location.id } },
                                                  },
                                                },
                                              })
      end

      let(:expected_generic_event_attributes) do
        {
          'id' => nil,
          'eventable_id' => move.id,
          'eventable_type' => 'Move',
          'type' => 'GenericEvent::MoveRedirect',
          'notes' => 'foo',
          'created_by' => 'unknown',
          'details' => {
            'to_location_id' => move.from_location.id,
            'move_type' => 'prison_transfer',
          },
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
end
