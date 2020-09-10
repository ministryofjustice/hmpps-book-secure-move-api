RSpec.describe GenericEvent::MoveReject do
  subject(:generic_event) { build(:event_move_reject) }

  it_behaves_like 'a move event'

  it { is_expected.to validate_inclusion_of(:rejection_reason).in_array(Move::REJECTION_REASONS) }

  describe '#trigger' do
    subject(:generic_event) { build(:event_move_reject, details: details, eventable: eventable) }

    before do
      allow(eventable).to receive(:rebook)
    end

    let(:details) do
      {
        rejection_reason: 'no_space_at_receiving_prison',
        cancellation_reason_comment: 'Wibble',
        rebook: rebook,
      }
    end
    let(:eventable) { build(:move) }
    let(:rebook) { false }

    it 'does not persist changes to the eventable' do
      generic_event.trigger

      expect(generic_event.eventable).not_to be_persisted
    end

    it 'sets the eventable `status` to cancelled' do
      expect { generic_event.trigger }.to change(eventable, :status).from('requested').to('cancelled')
    end

    it 'sets the eventable `rejection_reason` to no_space_at_receiving_prison' do
      expect { generic_event.trigger }.to change(eventable, :rejection_reason).from(nil).to('no_space_at_receiving_prison')
    end

    it 'sets the eventable `cancellation_reason` to rejected' do
      expect { generic_event.trigger }.to change(eventable, :cancellation_reason).from(nil).to('rejected')
    end

    it 'sets the eventable `cancellation_reason_comment`' do
      expect { generic_event.trigger }.to change(eventable, :cancellation_reason_comment).from(nil).to('Wibble')
    end

    context 'when the user wants to rebook the move' do
      let(:rebook) { true }

      it 'rebooks the move' do
        generic_event.trigger
        expect(eventable).to have_received(:rebook)
      end
    end

    context 'when the user does not want to rebook the move' do
      let(:rebook) { false }

      it 'does not rebook the move' do
        generic_event.trigger
        expect(eventable).not_to have_received(:rebook)
      end
    end
  end

  describe '#for_feed' do
    subject(:generic_event) { create(:event_move_reject) }

    context 'when the move_type is present' do
      let(:expected_json) do
        {
          'id' => generic_event.id,
          'type' => 'GenericEvent::MoveReject',
          'notes' => 'Flibble',
          'created_at' => be_a(Time),
          'updated_at' => be_a(Time),
          'occurred_at' => be_a(Time),
          'recorded_at' => be_a(Time),
          'eventable_id' => generic_event.eventable_id,
          'eventable_type' => 'Move',
          'details' => {
            'rejection_reason' => 'no_space_at_receiving_prison',
            'cancellation_reason_comment' => 'It was a mistake',
            'rebook' => false,
          },
        }
      end

      it 'generates a feed document' do
        expect(generic_event.for_feed).to include_json(expected_json)
      end
    end
  end

  describe '.from_event' do
    let(:move) { create(:move) }
    let(:event) do
      create(:event, :reject, :locations, eventable: move,
                                          details: {
                                            event_params: {
                                              attributes: {
                                                rejection_reason: 'no_space_at_receiving_prison',
                                                cancellation_reason_comment: 'a comment',
                                                rebook: 'false',
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
        'type' => 'GenericEvent::MoveReject',
        'notes' => 'foo',
        'created_by' => 'unknown',
        'details' => {
          'rejection_reason' => 'no_space_at_receiving_prison',
          'cancellation_reason_comment' => 'a comment',
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
