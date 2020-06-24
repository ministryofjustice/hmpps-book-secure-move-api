# frozen_string_literal: true

RSpec.shared_context 'with mock redis' do
  let(:mock_redis) { MockRedis.new }

  before do
    allow(Redis).to receive(:new) { mock_redis }
  end
end
