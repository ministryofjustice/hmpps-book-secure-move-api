require 'rails_helper'

RSpec.describe GenericEvent::JourneyStart do
  subject(:generic_event) { build(:event_journey_start) }

  it_behaves_like 'a journey event', :start

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
    let(:supplier) { create(:supplier, :serco) }

    before do
      generic_event.vehicle_reg = nil
      generic_event.supplier = supplier
      allow(Sentry).to receive(:capture_message)
    end

    it 'does not set the vehicle_registration on the eventable and logs to sentry' do
      expect(Sentry).to receive(:capture_message).with('GenericEvent::JourneyStart created without vehicle_reg', level: 'warning', extra: { supplier: supplier&.key })
      generic_event.trigger
      expect(generic_event.eventable.vehicle_registration).to eq('AB12 CDE')
    end
  end
end
