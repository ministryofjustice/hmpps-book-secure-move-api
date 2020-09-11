RSpec.describe GenericEvent::MoveStart do
  subject(:generic_event) { build(:event_move_start) }

  it_behaves_like 'a move event'

  describe '#trigger' do
    it 'does not persist changes to the eventable' do
      generic_event.trigger
      expect(generic_event.eventable).not_to be_persisted
    end

    it 'sets the eventable `status` to in_transit' do
      expect { generic_event.trigger }.to change { generic_event.eventable.status }.from('requested').to('in_transit')
    end
  end

  describe '.from_event' do
    let(:move) { create(:move) }

    let(:event) do
      create(:event, :start, :locations, eventable: move,
                                         details: {
                                           event_params: {
                                             attributes: {
                                               notes: 'foo',
                                             },
                                           },
                                         })
    end

    let(:expected_generic_event_attributes) do
      {
        'id' => nil,
        'eventable_id' => move.id,
        'eventable_type' => 'Move',
        'type' => 'GenericEvent::MoveStart',
        'notes' => 'foo',
        'created_by' => 'unknown',
        'details' => {},
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
