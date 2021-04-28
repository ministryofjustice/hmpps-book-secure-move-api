require 'rails_helper'

RSpec.describe GenericEvent::PerCourtHearing do
  subject(:generic_event) { build(:event_per_court_hearing) }

  it_behaves_like 'an event with details', :is_virtual, :is_trial, :court_listing_at, :started_at, :ended_at, :agreed_at, :court_outcome
  it_behaves_like 'an event with relationships', location_id: :locations
  it_behaves_like 'an event with eventable types', 'PersonEscortRecord'
  it_behaves_like 'an event requiring a location', :location_id
  it_behaves_like 'an event with a location in the feed', :location_id

  it { is_expected.to allow_value(true).for(:is_virtual) }
  it { is_expected.to allow_value(false).for(:is_virtual) }
  it { is_expected.to allow_value(true).for(:is_trial) }
  it { is_expected.to allow_value(false).for(:is_trial) }
  it { is_expected.to validate_presence_of(:court_listing_at) }
  it { is_expected.to validate_presence_of(:started_at) }
  it { is_expected.to validate_presence_of(:ended_at) }
  it { is_expected.to validate_presence_of(:court_outcome) }

  %i[court_listing_at started_at ended_at agreed_at].each do |details_attribute|
    context "when #{details_attribute} is not a valid iso8601 date" do
      before do
        generic_event.public_send("#{details_attribute}=", '2019/01/01')
      end

      it { is_expected.not_to be_valid }
    end
  end
end
