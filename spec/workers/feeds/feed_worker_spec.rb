require 'rails_helper'

RSpec.describe Feeds::FeedWorker, type: :worker do
  let(:reports_feed_instance) { instance_double(CloudData::ReportsFeed) }
  let(:feed_instance) { instance_double(Feeds::Event, { call: 'feed_data' }) }

  before do
    allow(reports_feed_instance).to receive(:write)
    allow(CloudData::ReportsFeed).to receive(:new).and_return(reports_feed_instance)
  end

  Feeds::AllWorker.feed_names.each do |feed_name|
    context "when called with #{feed_name}" do
      let(:feed_class) { "Feeds::#{feed_name.titleize}".constantize }

      before do
        allow(feed_class).to receive(:new).and_return(feed_instance)
      end

      it 'calls the correct methods' do
        described_class.new.perform(feed_name, Date.yesterday.to_s)

        expect(feed_class).to have_received(:new).once.with(Date.yesterday.beginning_of_day, Date.yesterday.end_of_day)
        expect(reports_feed_instance).to have_received(:write).once.with('feed_data', feed_name.pluralize, Date.yesterday)
      end
    end
  end
end
