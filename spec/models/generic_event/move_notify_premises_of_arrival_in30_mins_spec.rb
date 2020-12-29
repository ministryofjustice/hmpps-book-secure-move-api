RSpec.describe GenericEvent::MoveNotifyPremisesOfArrivalIn30Mins do
  subject(:generic_event) { build(:event_move_notify_premises_of_arrival_in30_mins) }

  it { is_expected.to validate_inclusion_of(:eventable_type).in_array(%w[Move]) }

  describe '#event_classification' do
    it 'returns :notification' do
      event = described_class.new

      expect(event.event_classification).to eq :notification
    end

    it 'is automatically assigned on creation' do
      event = create(:event_move_notify_premises_of_arrival_in30_mins, classification: nil)

      expect(event.classification).to eq 'notification'
    end
  end
end
