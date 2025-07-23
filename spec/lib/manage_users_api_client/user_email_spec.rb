# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ManageUsersApiClient::UserEmail, :with_hmpps_authentication do
  describe '.get' do
    context 'with a username that exists in the API' do
      let(:response_body) { file_fixture('manage_users_api/get_user_email_200.json').read }
      let(:response_status) { 200 }

      it 'makes an API call and returns the expected email' do
        response = described_class.get('ALICE_APPLE')
        expect(response).to eq('alice.apple@example.com')
      end

      it 'calls fetch_response for username lookup' do
        expect(described_class).to receive(:fetch_response).with('ALICE_APPLE').and_call_original
        described_class.get('ALICE_APPLE')
      end
    end

    context 'when username is already an email address' do
      it 'returns the email address directly without making an API call' do
        expect(described_class).not_to receive(:fetch_response)
        response = described_class.get('alice.apple@example.com')
        expect(response).to eq('alice.apple@example.com')
      end

      it 'handles various email formats correctly' do
        email_addresses = [
          'user@example.com',
          'user.name@example.com',
          'user+tag@example.co.uk',
          'user123@subdomain.example.org',
        ]

        email_addresses.each do |email|
          expect(described_class).not_to receive(:fetch_response)
          response = described_class.get(email)
          expect(response).to eq(email)
        end
      end
    end

    context 'when username is nil or empty' do
      it 'returns nil for nil username without making API call' do
        expect(described_class).not_to receive(:fetch_response)
        response = described_class.get(nil)
        expect(response).to be_nil
      end

      it 'returns nil for empty string without making API call' do
        expect(described_class).not_to receive(:fetch_response)
        response = described_class.get('')
        expect(response).to be_nil
      end
    end

    context 'when API returns 204 No Content' do
      let(:response_status) { 204 }

      it 'returns nil' do
        response = described_class.get('USER_WITH_NO_EMAIL')
        expect(response).to be_nil
      end
    end

    context 'when API returns error response' do
      let(:response_body) { file_fixture('manage_users_api/get_user_email_404.json').read }
      let(:response_status) { 404 }

      it 'returns nil' do
        response = described_class.get('UN_KNOWN')
        expect(response).to be_nil
      end
    end

    context 'when OAuth2::Error is raised' do
      before do
        allow(described_class).to receive(:fetch_response).and_raise(OAuth2::Error.new('Unauthorized'))
      end

      it 'returns nil' do
        response = described_class.get('SOME_USER')
        expect(response).to be_nil
      end
    end
  end
end
