RSpec.describe Feeds::Move do
  subject(:feed) { described_class.new(updated_at_from, updated_at_to) }

  let(:updated_at_from) { Time.zone.now.beginning_of_day - 1.day }
  let(:updated_at_to) { Time.zone.now.end_of_day - 1.day }

  describe '#call' do
    let!(:on_start_move) { create(:move, updated_at: updated_at_from) }
    let!(:on_end_move) { create(:move, updated_at: updated_at_to) }

    let(:expected_json) do
      [on_start_move, on_end_move].sort_by(&:id).map { |move| JSON.parse(move.for_feed.to_json) }
    end

    it 'returns correctly formatted feed' do
      result = feed.call
      result = result.split("\n")
      result = result.map { |move| JSON.parse(move) }

      expect(result).to include_json(expected_json)
    end
  end
end
