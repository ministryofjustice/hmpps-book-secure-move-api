require 'rails_helper'

RSpec.describe GenericEvent::MoveReject do
  subject(:generic_event) { build(:event_move_reject) }

  it_behaves_like 'an event with details', :rejection_reason, :cancellation_reason_comment, :rebook
  it_behaves_like 'a move event'

  it { is_expected.to validate_inclusion_of(:rejection_reason).in_array(Move::REJECTION_REASONS) }

  describe '#trigger' do
    subject(:generic_event) { build(:event_move_reject, details:, eventable:) }

    before do
      allow(eventable).to receive(:rebook)
    end

    let(:details) do
      {
        rejection_reason: 'no_space_at_receiving_prison',
        cancellation_reason_comment: 'Wibble',
        rebook:,
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

  describe 'after_create' do
    subject(:move_reject) { create(:event_move_reject, eventable: move) }

    before do
      # Create a MoveProposed event with a creator
      create(:event_move_proposed, eventable: move, created_by: username)
      allow(move).to receive_messages(cancelled?: false, generic_events: move.generic_events)
    end

    let(:move) { create(:move) }
    let(:mailer_double) { instance_double(ActionMailer::MessageDelivery, deliver_now!: nil) }
    let(:username) { 'a_user_name' }
    let(:email) { 'user@example.com' }

    context 'when there is a username for the person who proposed the move' do
      before do
        allow(ManageUsersApiClient::UserEmail).to receive(:get).with(username).and_return(email)
        allow(MoveRejectMailer).to receive(:notify).with(email, move, an_instance_of(described_class)).and_return(mailer_double)
      end

      it 'sends a notification email' do
        expect(mailer_double).to receive(:deliver_now!)
        move_reject
      end

      context 'and that username is an email address' do
        let(:username) { 'alice@example.com' }

        before do
          allow(MoveRejectMailer).to receive(:notify).with('alice@example.com', move, an_instance_of(described_class)).and_return(mailer_double)
        end

        it 'sends a notification email to the username' do
          expect(mailer_double).to receive(:deliver_now!)
          move_reject
        end
      end
    end

    context 'when there is no email address for that username' do
      before do
        allow(ManageUsersApiClient::UserEmail).to receive(:get).with(username).and_return(nil)
      end

      it 'does not send a notification email' do
        expect(MoveRejectMailer).not_to receive(:notify)

        move_reject
      end
    end

    context 'when there is no MoveProposed event' do
      before do
        # Return an empty relation
        empty_relation = Move.none
        allow(move).to receive_messages(cancelled?: false, generic_events: empty_relation)
      end

      it 'does not send a notification email' do
        expect(MoveRejectMailer).not_to receive(:notify)

        move_reject
      end
    end

    context 'when the move is already cancelled/rejected' do
      before do
        allow(move).to receive(:cancelled?).and_return(true)
      end

      it 'does not send a notification email' do
        expect(MoveRejectMailer).not_to receive(:notify)

        move_reject
      end
    end
  end

  describe '#for_feed' do
    subject(:generic_event) { create(:event_move_reject) }

    context 'when rebook is present' do
      before do
        generic_event.rebook = true
      end

      let(:expected_json) do
        {
          'id' => generic_event.id,
          'type' => 'MoveReject',
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
            'rebook' => true,
          },
        }
      end

      it 'generates a feed document' do
        expect(generic_event.for_feed).to include_json(expected_json)
      end
    end

    context 'when rebook is absent' do
      before do
        generic_event.details.delete('rebook')
      end

      let(:expected_json) do
        {
          'id' => generic_event.id,
          'type' => 'MoveReject',
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
end
