require 'rails_helper'

RSpec.describe Feeds::AllWorker, type: :worker do
  let(:ap_feed_instance) { instance_double(CloudData::AnalyticalPlatformFeed) }
  let(:feed_instance) { instance_double(Feeds::Jpc, { call: feed_data }) }
  let(:feed_data) do
    {
      move: 'move_data',
      journey: 'journey_data',
      event: 'event_data',
      profile: 'profile_data',
      person: 'person_data',
    }
  end

  before do
    allow(ap_feed_instance).to receive(:write)
    allow(CloudData::AnalyticalPlatformFeed).to receive(:new).and_return(ap_feed_instance)
    allow(Feeds::Jpc).to receive(:new).and_return(feed_instance)
  end

  it 'calls the correct methods' do
    described_class.new.perform(Date.yesterday.to_s)

    expect(Feeds::Jpc).to have_received(:new).once.with(Date.yesterday.beginning_of_day, Date.yesterday.end_of_day)
    expect(ap_feed_instance).to have_received(:write).with('move_data', 'moves', Date.yesterday)
    expect(ap_feed_instance).to have_received(:write).with('journey_data', 'journeys', Date.yesterday)
    expect(ap_feed_instance).to have_received(:write).with('event_data', 'events', Date.yesterday)
    expect(ap_feed_instance).to have_received(:write).with('profile_data', 'profiles', Date.yesterday)
    expect(ap_feed_instance).to have_received(:write).with('person_data', 'people', Date.yesterday)
  end
end
