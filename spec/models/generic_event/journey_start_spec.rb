require 'rails_helper'

RSpec.describe GenericEvent::JourneyStart do
  subject(:generic_event) { build(:event_journey_start) }

  it_behaves_like 'a journey event', :start
  it_behaves_like 'an event that will require a vehicle registration'

  context 'when supplied a vehicle_reg' do
    before do
      generic_event.vehicle_reg = 'a vehicle reg'
    end

    it 'sets the vehicle_registration on the eventable' do
      generic_event.trigger
      expect(generic_event.eventable.vehicle_registration).to eq(generic_event.vehicle_reg)
    end
  end

  context 'when not supplied a vehicle_reg' do
    before do
      generic_event.vehicle_reg = nil
    end

    it 'does not set the vehicle_registration on the eventable' do
      generic_event.trigger
      expect(generic_event.eventable.vehicle_registration).to eq('AB12 CDE')
    end
  end

  context 'when supplied a vehicle_depot' do
    before do
      generic_event.vehicle_depot = 'a vehicle depot'
    end

    it 'sets the vehicle_depot on the journey' do
      generic_event.trigger
      expect(generic_event.eventable.vehicle_depot).to eq(generic_event.vehicle_depot)
    end
  end

  context 'when not supplied a vehicle_depot' do
    before do
      generic_event.eventable.vehicle_depot = 'Home Depot'
      generic_event.vehicle_depot = nil
    end

    it 'does not set the vehicle_depot on the journey' do
      generic_event.trigger
      expect(generic_event.eventable.vehicle_depot).to eq('Home Depot')
    end
  end

  it_behaves_like 'an event that must not occur after', 'GenericEvent::JourneyComplete'
  it_behaves_like 'an event that must not occur before', 'GenericEvent::MoveStart'
end
