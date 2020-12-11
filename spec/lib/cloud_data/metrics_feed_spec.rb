require 'rails_helper'

RSpec.describe CloudData::MetricsFeed do
  let(:feed) { described_class.new('bucket', client) }
  let(:client) { Aws::S3::Client.new(stub_responses: true) }

  describe 'stale?' do
    subject(:stale) { feed.stale?('key', expired_before) }

    let(:expired_before) { 10.minutes.ago }

    context 'when the object does not exist' do
      let(:client) { Aws::S3::Client.new(stub_responses: { head_object: { status_code: 404, headers: {}, body: '' } }) }

      it 'is stale' do
        expect(stale).to be(true)
      end
    end

    context 'when the object exists and is older than expired_before' do
      let(:client) { Aws::S3::Client.new(stub_responses: { head_object: { last_modified: 3.hours.ago } }) }

      it 'is stale' do
        expect(stale).to be(true)
      end
    end

    context 'when the object exists and is newer than expired_before' do
      let(:client) { Aws::S3::Client.new(stub_responses: { head_object: { last_modified: Time.zone.now } }) }

      it 'is not stale' do
        expect(stale).to be(false)
      end
    end

    context 'when expired_before is nil' do
      let(:expired_before) { nil }

      it 'is stale' do
        expect(stale).to be(true)
      end
    end
  end

  describe 'update' do
    before do
      allow(client).to receive(:put_object)
      feed.update('key', 'body')
    end

    it 'puts the object in the bucket' do
      expect(client).to have_received(:put_object).with(bucket: 'bucket', key: 'key', body: 'body')
    end
  end
end
