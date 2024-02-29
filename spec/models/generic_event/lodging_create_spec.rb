require 'rails_helper'

RSpec.describe GenericEvent::LodgingCreate do
  subject(:generic_event) { build(:event_lodging_create, details:) }

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
  it_behaves_like 'an event with eventable types', 'Lodging'
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
end
