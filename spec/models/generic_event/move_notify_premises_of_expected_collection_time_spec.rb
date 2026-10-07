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
    it "defaults to the move's from_location when there is no previous MoveLodgingStart" do
      generic_event.valid?

      expect(generic_event.location).to eq(move.from_location)
    end

    it 'does not override an explicitly supplied location_id' do
      supplied_location = create(:location)
      generic_event.location_id = supplied_location.id

      generic_event.valid?

      expect(generic_event.location).to eq(supplied_location)
    end

    context 'when a MoveLodgingStart occurred before the pickup time' do
      let(:lodge_location) { create(:location) }

      let!(:lodging_start) do
        create(:event_move_lodging_start, eventable: move, occurred_at: Time.zone.parse('2020-06-15T20:00:00+01:00'),
                                          details: { location_id: lodge_location.id, reason: 'overnight_lodging' })
      end

      it "resolves to the lodging's location rather than the move's original from_location" do
        generic_event.valid?

        expect(generic_event.location).to eq(lodge_location)
      end
    end

    context 'when the only MoveLodgingStart occurs after the pickup time' do
      let!(:lodging_start) do
        create(:event_move_lodging_start, eventable: move, occurred_at: Time.zone.parse('2020-06-17T08:00:00+01:00'),
                                          details: { location_id: create(:location).id, reason: 'overnight_lodging' })
      end

      it "still defaults to the move's from_location" do
        generic_event.valid?

        expect(generic_event.location).to eq(move.from_location)
      end
    end

    context 'when there are multiple prior MoveLodgingStart events' do
      let(:latest_lodge_location) { create(:location) }

      let!(:earlier_lodging_start) do
        create(:event_move_lodging_start, eventable: move, occurred_at: Time.zone.parse('2020-06-10T20:00:00+01:00'),
                                          details: { location_id: create(:location).id, reason: 'overnight_lodging' })
      end

      let!(:latest_lodging_start) do
        create(:event_move_lodging_start, eventable: move, occurred_at: Time.zone.parse('2020-06-15T20:00:00+01:00'),
                                          details: { location_id: latest_lodge_location.id, reason: 'overnight_lodging' })
      end

      it 'resolves to the most recent lodging start before the pickup time' do
        generic_event.valid?

        expect(generic_event.location).to eq(latest_lodge_location)
      end
    end

    context 'when occurred_at is later than expected_at, and a lodging starts in between' do
      let(:occurred_at) { Time.zone.parse('2020-06-20T09:00:00+01:00') }

      let!(:lodging_start) do
        create(:event_move_lodging_start, eventable: move, occurred_at: Time.zone.parse('2020-06-18T00:00:00+01:00'),
                                          details: { location_id: create(:location).id, reason: 'overnight_lodging' })
      end

      before { generic_event.expected_at = '2020-06-16T10:20:30+01:00' }

      it 'is driven by the pickup time (expected_at) rather than when the notification was recorded (occurred_at)' do
        generic_event.valid?

        expect(generic_event.location).to eq(move.from_location)
      end
    end
  end
end
