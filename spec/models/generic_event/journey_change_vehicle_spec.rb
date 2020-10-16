RSpec.describe GenericEvent::JourneyChangeVehicle do
  subject(:generic_event) { build(:event_journey_change_vehicle) }

  it_behaves_like 'an event with details', :vehicle_reg, :previous_vehicle_reg
  it_behaves_like 'an event with eventable types', 'Journey'
  it_behaves_like 'an event that specifies a vehicle registration'

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

  describe 'before create' do
    context 'when the journey has a vehicle_registration' do
      before do
        generic_event.eventable.vehicle_registration = 'boop'
      end

      it 'sets the previous_vehicle_reg' do
        expect { generic_event.save }.to change(generic_event, :previous_vehicle_reg)
          .from(nil)
          .to(generic_event.eventable.vehicle_registration)
      end
    end

    context 'when the journey vehicle information is nil' do
      before do
        generic_event.eventable.vehicle = nil
      end

      it 'sets the previous_vehicle_reg' do
        expect { generic_event.save }.not_to change(generic_event, :previous_vehicle_reg).from(nil)
      end

      it 'is valid' do
        expect { generic_event.save }.not_to raise_error
      end
    end
  end
end
