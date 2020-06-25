# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::AllocationsController do
  let(:supplier) { create(:supplier) }
  let!(:application) { create(:application, owner_id: supplier.id) }
  let!(:access_token) { create(:access_token, application: application).token }
  let(:response_json) { JSON.parse(response.body) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:headers) do
    {
      'CONTENT_TYPE': content_type,
      'Accept': 'application/vnd.api+json; version=2',
      'Authorization' => "Bearer #{access_token}",
    }
  end

  describe 'GET /allocations' do
    before do
      get '/api/allocations', params: params, headers: headers
    end

    context 'when not including the include query param' do
      let!(:allocation) { create(:allocation, :with_moves) }
      let(:params) { {} }

      it 'returns no included relationships ' do
        expect(response_json).not_to include('included')
      end
    end
  end
end
