# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sessions::UserTokenRefreshService do
  subject(:service) { described_class.new(user_token) }

  let!(:user_token) { create :user_token }

  before do
    # TODO: Setup environment variables and UserToken with an expired access token
  end

  it 'works' do
    pending
    service.refresh
  end
end
