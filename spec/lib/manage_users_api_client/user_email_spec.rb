# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ManageUsersApiClient::UserEmail, :with_hmpps_authentication do
  describe '.get' do
    let(:response) { described_class.get('ALICE_APPLE') }

    let(:response_body) { file_fixture('manage_users_api/get_user_email_200.json').read }

    let(:response_status) { 200 }

    it 'returns the expected email' do
      expect(response).to eq('alice.apple@example.com')
    end
  end

  describe '.get with errors' do
    let(:response) { described_class.get('UN_KNOWN') }

    let(:response_body) { file_fixture('manage_users_api/get_user_email_404.json').read }

    let(:response_status) { 404 }

    it 'returns nil' do
      expect(response).to be_nil
    end
  end
end
