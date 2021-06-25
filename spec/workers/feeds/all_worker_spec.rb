require 'rails_helper'

RSpec.describe Feeds::AllWorker, type: :worker do
  before do
    allow(Feeds::FeedWorker).to receive(:perform_async)
  end

  it 'calls the FeedWorkers with the specified date' do
    date = Date.new(2021)
    described_class.new.perform(date.to_s)

    described_class.feed_names.each do |feed_name|
      expect(Feeds::FeedWorker).to have_received(:perform_async).with(feed_name, date)
    end
  end
end
