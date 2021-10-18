RSpec.shared_examples 'an event that will require a vehicle registration' do
  context 'when not supplied a vehicle_reg' do
    let(:supplier) { create(:supplier, :serco) }

    before do
      generic_event.vehicle_reg = nil
      generic_event.supplier = supplier
      allow(Sentry).to receive(:capture_message)
    end

    it 'logs to sentry' do
      expect(Sentry).to receive(:capture_message).with("#{generic_event.class} created without vehicle_reg", level: 'warning', extra: { supplier: supplier&.key })
      generic_event.trigger
    end
  end
end
