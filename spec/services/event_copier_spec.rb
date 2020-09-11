RSpec.describe EventCopier do
  subject(:service) { described_class.new }

  context 'when the STI matched by the eventable and event name exists' do
    let!(:event) { create(:event, :cancel, eventable: journey, details: details) }
    let(:journey) { create(:journey) }

    context 'when the generic_event has invalid details' do
      let(:details) do
        {
          event_params: {
            attributes: {
              cancellation_reason: 'invalid_reason',
              cancellation_reason_comment: 'something of note',
            },
          },
        }
      end

      it 'returns the correct report' do
        expect(service.call).to eq(expected_report)
      end

      it 'does not create a GenericEvent' do
        expect { service.call }.not_to change(GenericEvent, :count)
      end
    end

    context 'when the generic_event has valid details' do
      let(:details) do
        {
          event_params: {
            attributes: {
              cancellation_reason: 'made_in_error',
              cancellation_reason_comment: 'something of note',
            },
          },
        }
      end

      it 'returns the correct report' do
        expected_report = {
          failure_count: 0,
          success_count: 1,
          errors: [],
        }

        expect(service.call).to eq(expected_report)
      end

      it 'creates a GenericEvent' do
        expect { service.call }.to change(GenericEvent, :count).by(1)
      end
    end
  end

  context 'when the STI matched by the eventable and event name does not exist' do
    it 'skips the event'
  end
end
