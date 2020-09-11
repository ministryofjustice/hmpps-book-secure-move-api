RSpec.describe EventCopier do
  subject(:service) { described_class.new(dry_run: dry_run) }

  let!(:event) { create(:event, :cancel, eventable: move, details: details) }
  let(:move) { create(:move) }
  let(:dry_run) { false }

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

    context 'when we are in a dry run' do
      let(:dry_run) { true }

      it 'returns the correct report' do
        expected_report = {
          failure_count: 1,
          success_count: 0,
          errors: [
            {
              'id' => event.id,
              'errors' => {
                cancellation_reason: ['is not included in the list'],
              },
            },
          ],
        }

        expect(service.call).to eq(expected_report)
      end
    end

    context 'when we are not in a dry run' do
      let(:dry_run) { false }

      it 'returns the correct report' do
        expected_report = {
          failure_count: 1,
          success_count: 0,
          errors: [
            {
              'id' => event.id,
              'errors' => {
                cancellation_reason: ['is not included in the list'],
              },
            },
          ],
        }

        expect(service.call).to eq(expected_report)
      end
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

    context 'when we are in a dry run' do
      let(:dry_run) { true }

      it 'returns the correct report' do
        expected_report = {
          failure_count: 0,
          success_count: 1,
          errors: [],
        }

        expect(service.call).to eq(expected_report)
      end

      it 'does not create a GenericEvent' do
        expect { service.call }.not_to change(GenericEvent::MoveCancel, :count)
      end
    end

    context 'when we are not in a dry run' do
      let(:dry_run) { false }

      it 'returns the correct report' do
        expected_report = {
          failure_count: 0,
          success_count: 1,
          errors: [],
        }

        expect(service.call).to eq(expected_report)
      end

      it 'creates a GenericEvent' do
        expect { service.call }.to change(GenericEvent::MoveCancel, :count).by(1)
      end
    end
  end
end
