require 'rails_helper'

RSpec.describe GenericEvent, type: :model do
  subject(:generic_event) { build(:event_move_cancel) }

  it { is_expected.to belong_to(:eventable) }
  it { is_expected.to validate_presence_of(:eventable) }
  it { is_expected.to validate_presence_of(:type) }
  it { is_expected.to validate_presence_of(:occurred_at) }
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
end
