require 'rails_helper'

RSpec.describe GenericEvent::MoveLodgingEnd do
  subject(:generic_event) { build(:event_move_lodging_end, occurred_at:, eventable: move, details:) }

  let(:move) { build(:move) }
  let!(:lodging) { build(:lodging, move:, start_date: occurred_at, location: lodge_location, status: 'started') }
  let(:occurred_at) { Date.new(2020, 1, 1) }
  let(:lodge_location) { create(:location) }

  let(:details) do
    {
      location_id: lodge_location.id,
      reason: 'overnight_lodging',
    }
  end

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Move]) }

  it_behaves_like 'an event with relationships', location_id: :locations
  it_behaves_like 'an event requiring a location', :location_id

  describe '#trigger' do
    before do
      move.save!
      lodging.save!
    end

    it 'updates the lodging state' do
      generic_event.trigger
      expect(lodging.reload.status).to eq('completed')
    end
  end
end
