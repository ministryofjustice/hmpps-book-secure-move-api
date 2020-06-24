# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::AllocationsController do
  include ActiveJob::TestHelper

  describe 'POST /allocations' do
    let(:response_json) { JSON.parse(response.body) }
    let(:moves_count) { 2 }
    let(:allocation_attributes) do
      {
        date: Date.today,
        moves_count: moves_count,
        prisoner_category: :b,
        sentence_length: :short,
        other_criteria: 'curly hair',
        requested_by: 'Iama Requestor',
        complete_in_full: true,
      }
    end
    let!(:from_location) { create :location, suppliers: [supplier] }
    let!(:to_location) { create :location }

    let(:data) do
      {
        type: 'allocations',
        attributes: allocation_attributes,
        relationships: {
          from_location: { data: { type: 'locations', id: from_location.id } },
          to_location: { data: { type: 'locations', id: to_location.id } },
        },
      }
    end

    let(:supplier) { create(:supplier) }
    let!(:application) { create(:application, owner_id: supplier.id) }
    let(:access_token) { create(:access_token, application: application).token }
    let(:content_type) { ApiController::CONTENT_TYPE }
    let(:headers) do
      {
        'CONTENT_TYPE': content_type,
        'Accept': 'application/vnd.api+json; version=2',
        'Authorization' => "Bearer #{access_token}",
      }
    end

    before do
      post '/api/allocations', params: { data: data }, headers: headers, as: :json
    end

    context 'when not including the include query param' do
      it 'returns no included relationships' do
        expect(response_json).not_to include('included')
      end
    end
  end
end
