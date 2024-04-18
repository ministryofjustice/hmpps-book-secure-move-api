require 'rails_helper'

RSpec.describe GenericEvent::MoveLodgingStart do
  subject(:generic_event) { build(:event_move_lodging_start, occurred_at:, eventable: move, details:) }

  let(:move) { build(:move) }
  let!(:lodging) { build(:lodging, move:, start_date: occurred_at, location: lodge_location) }
  let(:occurred_at) { Date.new(2020, 1, 1) }
  let(:lodge_location) { create(:location) }

  let(:details) do
    {
      location_id: lodge_location.id,
      reason: 'overnight_lodging',
    }
  end

  let(:reasons) do
    %w[
      overnight_lodging
      lockout
      operation_hmcts
      court_cells
      operation_tornado
      operation_safeguard
      other
    ]
  end

  it_behaves_like 'an event with details', :reason
  it_behaves_like 'an event with relationships', location_id: :locations
  it_behaves_like 'an event requiring a location', :location_id
  it_behaves_like 'an event with a location in the feed', :location_id

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Move]) }
  it { is_expected.to validate_inclusion_of(:reason).in_array(reasons) }
  it { is_expected.to validate_presence_of(:reason) }

  describe '#trigger' do
    before do
      move.save!
      lodging.save!
    end

    it 'updates the lodging state' do
      generic_event.trigger
      expect(lodging.reload.status).to eq('started')
    end
  end
end
