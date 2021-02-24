require 'rails_helper'

RSpec.describe GenericEvent::PersonMoveVehicleBrokeDown do
  subject(:generic_event) { build(:event_person_move_vehicle_broke_down) }

  it_behaves_like 'an event with details', :supplier_personnel_numbers, :vehicle_reg, :reported_at, :postcode, :location_description
  it_behaves_like 'an event with relationships', location_id: :locations
  it_behaves_like 'an event with eventable types', 'Person', 'Move'
  it_behaves_like 'an event requiring a location', :location_id
  it_behaves_like 'an event that specifies a vehicle registration'
  it_behaves_like 'an event with a location in the feed', :location_id

  it { is_expected.to validate_presence_of(:supplier_personnel_numbers) }

  context 'when an invalid postcode is submitted' do
    before do
      generic_event.postcode = 'totally broken'
    end

    it { is_expected.not_to be_valid }
  end

  context 'when reported_at is not a valid iso8601 date' do
    before do
      generic_event.reported_at = '2019/01/01'
    end

    it { is_expected.not_to be_valid }
  end

  context 'when the postcode and the location_description are missing' do
    before do
      generic_event.postcode = nil
      generic_event.location_description = nil
    end

    it { is_expected.not_to be_valid }
  end
end
