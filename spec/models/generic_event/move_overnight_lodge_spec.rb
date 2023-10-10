require 'rails_helper'

RSpec.describe GenericEvent::MoveOvernightLodge do
  subject(:generic_event) { build(:event_move_overnight_lodge, details:) }

  let(:details) do
    {
      start_date:,
      end_date:,
      described_class::LOCATION_ATTRIBUTE_KEY => create(:location).id,
    }
  end
  let(:start_date) { '2023-01-01' }
  let(:end_date) { '2023-01-02' }

  it_behaves_like 'an event with details', :start_date, :end_date
  it_behaves_like 'an event with relationships', described_class::LOCATION_ATTRIBUTE_KEY => :locations
  it_behaves_like 'a move event'
  it_behaves_like 'an event requiring a location', described_class::LOCATION_ATTRIBUTE_KEY
  it_behaves_like 'an event with a location in the feed', described_class::LOCATION_ATTRIBUTE_KEY

  it { is_expected.to validate_presence_of(:start_date) }
  it { is_expected.to validate_presence_of(:end_date) }

  context 'when the start_date format is not an iso8601 date' do
    let(:start_date) { '2023/01/01' }

    it { is_expected.to be_invalid }
  end

  context 'when the end_date format is not an iso8601 date' do
    let(:end_date) { '2023/01/02' }

    it { is_expected.to be_invalid }
  end

  context 'when the end_date is before the start_date' do
    let(:end_date) { '2022-12-31' }

    it { is_expected.to be_invalid }
  end

  context 'when the end_date is same as the start_date' do
    let(:end_date) { '2023-01-01' }

    it { is_expected.to be_invalid }
  end
end
