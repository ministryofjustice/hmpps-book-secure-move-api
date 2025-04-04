require 'rails_helper'

RSpec.describe 'User audit logs' do
  let(:ip_address) { '192.168.1.1' }
  let(:username)   { 'Test User' }
  let(:headers) do
    {
      'Content-Type' => ApiController::CONTENT_TYPE,
      'Authorization' => 'Bearer spoofed-token',
      'X-Client-IP' => ip_address,
      'X-Current-User' => username,
      'X-Transaction-Id' => SecureRandom.uuid,
    }
  end

  context 'when making API requests' do
    context 'when an IP address is provided' do
      before do
        get '/api/moves', headers: headers
      end

      it 'creates a user audit log record' do
        expect(UserAuditLog.count).to eq(1)
      end

      it 'stores the correct name' do
        expect(UserAuditLog.last.name).to eq('Test User')
      end

      it 'stores the correct IP address' do
        expect(UserAuditLog.last.ip_address).to eq(ip_address)
      end
    end

    context 'when making multiple requests with the same user and IP' do
      before do
        2.times { get '/api/moves', headers: headers }
      end

      it 'creates only one user audit log record' do
        expect(UserAuditLog.count).to eq(1)
      end
    end

    context 'when IP address is not provided' do
      before do
        get '/api/moves', headers: headers.except('X-Client-IP')
      end

      it 'does not create a user audit log record' do
        expect(UserAuditLog.count).to eq(0)
      end
    end

    context 'when username is not provided' do
      before do
        get '/api/moves', headers: headers.except('X-Current-User')
      end

      it 'does not create a user audit log record' do
        expect(UserAuditLog.count).to eq(0)
      end
    end
  end
end
