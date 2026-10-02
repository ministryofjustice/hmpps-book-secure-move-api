require 'rails_helper'

RSpec.describe GenericEvent::MoveNotifyPremisesOfDropOffEta do
  subject(:generic_event) { build(:event_move_notify_premises_of_drop_off_eta, eventable: move) }

  let(:move) { create(:move) }

  it_behaves_like 'an event with details', :expected_at
  it_behaves_like 'an event with relationships', location_id: :locations
  it_behaves_like 'an event requiring a location', :location_id
  it_behaves_like 'an event with a location in the feed', :location_id

  # NB: uses an unsaved eventable (unlike the `subject` above) since the shoulda matcher mutates
  # eventable_type on the record, and a persisted eventable_id combined with a bogus type causes
  # ActiveRecord to blow up trying to load the (now invalid) polymorphic association.
  it { expect(build(:event_move_notify_premises_of_drop_off_eta, location_id: create(:location).id)).to validate_inclusion_of(:eventable_type).in_array(%w[Move]) }
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
    it "defaults to the move's to_location" do
      generic_event.valid?

      expect(generic_event.location).to eq(move.to_location)
    end

    it 'does not override an explicitly supplied location_id' do
      supplied_location = create(:location)
      generic_event.location_id = supplied_location.id

      generic_event.valid?

      expect(generic_event.location).to eq(supplied_location)
    end

    %i[prison_recall video_remand].each do |move_trait|
      context "when the move is a #{move_trait} with no to_location" do
        let(:move) { create(:move, move_trait) }

        it 'is valid without a location' do
          expect(generic_event).to be_valid
          expect(generic_event.location).to be_nil
        end
      end
    end
  end
end
