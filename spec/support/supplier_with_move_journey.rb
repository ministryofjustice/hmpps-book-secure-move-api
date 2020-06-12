# frozen_string_literal: true

RSpec.shared_context 'with supplier with move and journey' do
  let(:supplier) { create(:supplier) }
  let(:application) { create(:application, owner_id: supplier.id) }
  let(:access_token) { create(:access_token, application: application).token }
  let(:headers) { { 'CONTENT_TYPE': content_type, 'Authorization': "Bearer #{access_token}" } }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:move) { create(:move) }
  let(:move_id) { move.id }
  let(:journey) { create(:journey, initial_journey_state, move: move) }
  let(:journey_id) { journey.id }
  let(:initial_journey_state) { :proposed }
end
