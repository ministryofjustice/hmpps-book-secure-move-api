# frozen_string_literal: true

RSpec.shared_context 'with supplier with spoofed access token' do
  let(:supplier) { create(:supplier) }
  let(:access_token) { 'spoofed-token' }
  # NB: In real environments (i.e. not in request specs) some rack/rails magic will automatically convert the header
  # IDEMPOTENCY_KEY to a case-insensitive IDEMPOTENCY-KEY. We sidestep that here by naming the key IDEMPOTENCY-KEY.
  let(:headers) { { 'CONTENT_TYPE': content_type, 'Authorization': "Bearer #{access_token}", 'IDEMPOTENCY-KEY': SecureRandom.uuid, 'X-Current-User': 'TEST_USER' } }
  let(:content_type) { ApiController::CONTENT_TYPE }
end
