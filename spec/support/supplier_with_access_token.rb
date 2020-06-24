# frozen_string_literal: true

RSpec.shared_context 'with supplier with access token' do
  let(:supplier) { create(:supplier) }
  let(:application) { create(:application, owner: supplier) } # , owner_id: supplier.id) }
  let(:access_token) { create(:access_token, application: application).token }
  let(:headers) { { 'CONTENT_TYPE': content_type, 'Authorization': "Bearer #{access_token}", 'IDEMPOTENCY_KEY': SecureRandom.uuid } }
  let(:content_type) { ApiController::CONTENT_TYPE }
end
