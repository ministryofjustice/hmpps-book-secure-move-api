RSpec.describe Event::MoveCancelV2 do
  subject(:event) { build(:event_move_cancel_v2, details: details) }

  let(:details) do
    {
      cancellation_reason: 'made_in_error',
      cancellation_reason_comment: 'Something or other',
    }
  end

  it 'validates cancellation_reason' do
    expect(event).to validate_inclusion_of(:cancellation_reason).in_array(Move::CANCELLATION_REASONS)
  end

  describe '#cancellation_reason' do
    it 'returns the cancellation_reason from the details' do
      expect(event.cancellation_reason).to eq('made_in_error')
    end
  end

  describe '#cancellation_reason_comment' do
    it 'returns the cancellation_reason_comment from the details' do
      expect(event.cancellation_reason_comment).to eq('Something or other')
    end
  end
end
