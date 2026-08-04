require 'rails_helper'

RSpec.describe GenericEvent::MoveApprove do
  subject(:generic_event) { build(:event_move_approve, eventable:, details:) }

  let(:details) do
    {
      date:,
    }
  end

  let(:eventable) { build(:move, :proposed) }
  let(:date) { '2019-01-01' }

  it { is_expected.to validate_presence_of(:date) }

  it_behaves_like 'an event with details', :date

  context 'when the date format is not an iso8601 date' do
    let(:date) { '2019/01/01' }

    it { is_expected.to be_invalid }
  end

  it_behaves_like 'a move event'

  describe '#trigger' do
    it 'does not persist changes to the eventable' do
      generic_event.trigger

      expect(generic_event.eventable).not_to be_persisted
    end

    it 'sets the eventable `status` to requested' do
      expect { generic_event.trigger }.to change { generic_event.eventable.status }.from('proposed').to('requested')
    end

    it 'sets the correct date' do
      expect { generic_event.trigger }.to change { generic_event.eventable.date }.from(eventable.date).to(Date.parse(generic_event.date))
    end
  end

  describe '#for_feed' do
    subject(:generic_event) { create(:event_move_approve) }

    let(:expected_json) do
      {
        'id' => generic_event.id,
        'type' => 'MoveApprove',
        'notes' => 'Flibble',
        'created_by' => 'TEST_USER',
        'created_at' => be_a(Time),
        'updated_at' => be_a(Time),
        'occurred_at' => be_a(Time),
        'recorded_at' => be_a(Time),
        'eventable_id' => generic_event.eventable_id,
        'eventable_type' => 'Move',
        'details' => {
          'date' => generic_event.date,
        },
      }
    end

    it 'generates a feed document' do
      expect(generic_event.for_feed).to include_json(expected_json)
    end
  end
end
