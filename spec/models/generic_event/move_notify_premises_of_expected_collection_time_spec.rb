require 'rails_helper'

RSpec.describe GenericEvent::MoveNotifyPremisesOfExpectedCollectionTime do
  subject(:generic_event) { build(:event_move_notify_premises_of_expected_collection_time, eventable: move, occurred_at:) }

  let(:move) { create(:move) }
  let(:occurred_at) { Time.zone.parse('2020-06-16T10:20:30+01:00') }

  it_behaves_like 'an event with details', :expected_at
  it_behaves_like 'an event with relationships', location_id: :locations
  it_behaves_like 'an event requiring a location', :location_id
  it_behaves_like 'an event with a location in the feed', :location_id

  # NB: uses an unsaved eventable (unlike the `subject` above) since the shoulda matcher mutates
  # eventable_type on the record, and a persisted eventable_id combined with a bogus type causes
  # ActiveRecord to blow up trying to load the (now invalid) polymorphic association.
  it { expect(build(:event_move_notify_premises_of_expected_collection_time, location_id: create(:location).id)).to validate_inclusion_of(:eventable_type).in_array(%w[Move]) }
  it { is_expected.to validate_presence_of(:expected_at) }

  it 'is valid when the expected_at value is a valid iso8601 datetime' do
    generic_event.expected_at = '2020-06-16T10:20:30+01:00'
    expect(generic_event).to be_valid
  end

  it 'is invalid when the expected_at value is not a valid iso8601 datetime' do
    generic_event.expected_at = '16-06-2020 10:20:30+01:00'
    expect(generic_event).not_to be_valid
  end

  describe 'location_id resolution' do
    it "defaults to the move's from_location when there is no active lodging" do
      generic_event.valid?

      expect(generic_event.location).to eq(move.from_location)
    end

    it 'does not override an explicitly supplied location_id' do
      supplied_location = create(:location)
      generic_event.location_id = supplied_location.id

      generic_event.valid?

      expect(generic_event.location).to eq(supplied_location)
    end

    context 'when an overnight lodge is in progress on the day of the event' do
      let!(:lodging) do
        create(:lodging, move:, location: lodge_location, start_date: '2020-06-15', end_date: '2020-06-16', status: 'started')
      end

      let(:lodge_location) { create(:location) }

      it "resolves to the lodging's location rather than the move's original from_location" do
        generic_event.valid?

        expect(generic_event.location).to eq(lodge_location)
      end
    end

    context 'when an overnight lodge covers the date but has not yet started' do
      let!(:lodging) do
        create(:lodging, move:, location: create(:location), start_date: '2020-06-15', end_date: '2020-06-16', status: 'proposed')
      end

      it "still defaults to the move's from_location" do
        generic_event.valid?

        expect(generic_event.location).to eq(move.from_location)
      end
    end
  end
end
