RSpec.describe Feeds::Journey do
  subject(:feed) { described_class.new(updated_at_from, updated_at_to) }

  let(:updated_at_from) { Time.zone.yesterday.beginning_of_day }
  let(:updated_at_to) { Time.zone.yesterday.end_of_day }

  describe '#call' do
    before do
      create(:journey, updated_at: updated_at_from)
      create(:journey, updated_at: updated_at_to)
    end

    let(:expected_json) do
      journey1 = JSON.parse(Journey.first.for_feed.to_json)
      journey2 = JSON.parse(Journey.second.for_feed.to_json)

      [journey1, journey2]
    end

    it 'returns correctly formatted feed' do
      result = described_class.new(updated_at_from, updated_at_to)

      parsed_result = result.split.map { |journey| JSON.parse(journey) }

      expect(parsed_result).to include_json(expected_json)
    end
  end
end
