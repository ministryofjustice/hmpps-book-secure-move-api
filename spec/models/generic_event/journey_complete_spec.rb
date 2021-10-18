require 'rails_helper'

RSpec.describe GenericEvent::JourneyComplete do
  subject(:generic_event) { build(:event_journey_complete) }

  it_behaves_like 'a journey event', :complete
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

  it_behaves_like 'an event that must not occur before', 'GenericEvent::JourneyStart'
  it_behaves_like 'an event that must not occur after', 'GenericEvent::MoveComplete'
end
