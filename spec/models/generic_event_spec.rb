require 'rails_helper'

RSpec.describe GenericEvent, type: :model do
  subject(:generic_event) { build(:event_move_cancel) }

  it { is_expected.to belong_to(:eventable) }
  it { is_expected.to validate_presence_of(:eventable) }
  it { is_expected.to validate_presence_of(:type) }
  it { is_expected.to validate_presence_of(:occurred_at) }
  it { is_expected.to validate_presence_of(:recorded_at) }
  it { is_expected.to validate_presence_of(:details) }
  it { is_expected.to validate_presence_of(:created_by) }

  it { expect(generic_event).to validate_inclusion_of(:created_by).in_array(%w[serco geoamey unknown]) }
  it { expect(described_class).to respond_to(:applied_order) }

  it 'updates the parent record when updated' do
    eventable = create(:move)
    event = create(:event_move_cancel, eventable: eventable)

    expect { event.update(occurred_at: event.occurred_at + 1.day) }.to change { eventable.reload.updated_at }
  end

  it 'updates the parent record when created' do
    eventable = create(:move)

    expect { create(:event_move_cancel, eventable: eventable) }.to change { eventable.reload.updated_at }
  end

  describe '#trigger' do
    subject(:generic_event) { create(:event_move_cancel) }

    it 'does nothing to the eventable attributes by default' do
      expect { generic_event.trigger }.not_to change { generic_event.reload.eventable.attributes }
    end
  end

  describe '#for_feed' do
    subject(:generic_event) { create(:event_move_cancel) }

    it 'returns the expected attributes' do
      expected_attributes = {
        'id' => generic_event.id,
        'type' => 'GenericEvent::MoveCancel',
        'notes' => 'Flibble',
        'created_at' => be_a(Time),
        'updated_at' => be_a(Time),
        'occurred_at' => be_a(Time),
        'recorded_at' => be_a(Time),
        'eventable_id' => generic_event.eventable_id,
        'eventable_type' => 'Move',
        'details' => { 'cancellation_reason' => 'made_in_error', 'cancellation_reason_comment' => 'It was a mistake'},
      }

      expect(generic_event.for_feed).to include_json(expected_attributes)
    end
  end
end
