# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Reference::PrisonTransferReasonsController do
  let(:headers) { { 'Authorization' => 'Bearer spoofed-token' } }
  let(:response_json) { JSON.parse(response.body) }

  describe 'GET /api/reference/prison_transfer_reasons' do
    let(:schema) { load_yaml_schema('get_prison_transfer_reasons_responses.yaml') }

    let!(:reason1) { create(:prison_transfer_reason) }
    let!(:reason2) { create(:prison_transfer_reason) }

    let(:data) do
      [
        {
          type: 'prison_transfer_reasons',
          attributes: {
            key: reason1.key,
            title: reason1.title,
            disabled_at: reason1.disabled_at,
          },
        },
        {
          type: 'prison_transfer_reasons',
          attributes: {
            key: reason2.key,
            title: reason2.title,
            disabled_at: reason2.disabled_at,
          },
        },
      ]
    end

    before do
      get '/api/reference/prison_transfer_reasons', headers:
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data:)
      end
    end
  end
end
