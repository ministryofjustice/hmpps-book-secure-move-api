require 'rails_helper'

RSpec.describe GenericEvent::JourneyChangeVehicle do
  subject(:generic_event) { build(:event_journey_change_vehicle) }

  it_behaves_like 'an event with details', :vehicle_reg, :previous_vehicle_reg
  it_behaves_like 'an event with eventable types', 'Journey'
  it_behaves_like 'an event that specifies a vehicle registration'

  it { is_expected.to validate_presence_of(:previous_vehicle_reg) }

  describe '#trigger' do
    it 'does not persist changes to the eventable' do
      generic_event.trigger
      expect(generic_event.eventable).not_to be_persisted
    end

    it 'sets the eventable `vehicle_registration` to the event `vehicle_reg`' do
      expect { generic_event.trigger }.to change { generic_event.eventable.vehicle_registration }
        .from(generic_event.eventable.vehicle_registration)
        .to(generic_event.vehicle_reg)
    end
  end
end
