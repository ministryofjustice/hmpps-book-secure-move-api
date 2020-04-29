# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::AllocationsController do
  include ActiveJob::TestHelper

  let(:response_json) { JSON.parse(response.body) }
  let(:resource_to_json) do
    JSON.parse(ActionController::Base.render(json: allocation, include: AllocationSerializer::INCLUDED_ATTRIBUTES))
  end

  describe 'POST /allocations' do
    let(:schema) { load_yaml_schema('post_allocations_responses.yaml') }

    let(:complex_case1_attributes) {
      {
        key: complex_case1.key,
        title: complex_case1.title,
        answer: false,
        allocation_complex_case_id: complex_case1.id,
      }
    }
    let(:complex_case2_attributes) {
      {
        key: complex_case2.key,
        title: complex_case2.title,
        answer: true,
        allocation_complex_case_id: complex_case2.id,
      }
    }
    let(:complex_cases_attributes) {
      [
        complex_case1_attributes,
        complex_case2_attributes,
      ]
    }
    let(:allocation_attributes) {
      {
        date: Date.today,
        moves_count: 2,
        prisoner_category: :b,
        sentence_length: :short,
        other_criteria: 'curly hair',
        complete_in_full: true,
        complex_cases: complex_cases_attributes,
      }
    }

    let!(:from_location) { create :location }
    let!(:to_location) { create :location }
    let!(:complex_case1) { create :allocation_complex_case }
    let!(:complex_case2) { create :allocation_complex_case, :self_harm }

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
    let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }
    let(:content_type) { ApiController::CONTENT_TYPE }

    before do
      next if RSpec.current_example.metadata[:skip_before]

      post '/api/v1/allocations', params: { data: data }, headers: headers, as: :json
    end

    context 'when not authorized', :skip_before, :with_invalid_auth_headers do
      let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
      let(:content_type) { ApiController::CONTENT_TYPE }
      let(:detail_401) { 'Token expired or invalid' }

      before do
        post '/api/v1/allocations', params: { data: data }, headers: headers, as: :json
      end

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      before do
        post '/api/v1/allocations', params: { data: data }, headers: headers, as: :json
      end

      it_behaves_like 'an endpoint that responds with error 415'
    end

    context 'when successful' do
      let(:allocation) { Allocation.find_by(from_location_id: from_location.id) }

      it_behaves_like 'an endpoint that responds with success 201'

      it 'creates a allocation', skip_before: true do
        expect { post '/api/v1/allocations', params: { data: data }, headers: headers, as: :json }
          .to change(Allocation, :count).by(1)
      end

      it 'audits the supplier' do
        expect(allocation.versions.map(&:whodunnit)).to eq([supplier.id])
      end

      it 'returns the correct data' do
        expect(response_json).to eq resource_to_json
      end

      it 'sets the correct number of complex_cases' do
        expect(response_json.dig('data', 'attributes', 'complex_cases').size).to match complex_cases_attributes.size
      end

      it 'sets the correct complex_cases attributes' do
        expect(response_json.dig('data', 'attributes', 'complex_cases').first).to match complex_case1_attributes.stringify_keys
      end

      context 'when specifying nil complex_cases attribute' do
        let(:complex_cases_attributes) { nil }

        it 'creates an allocation without complex cases' do
          expect(allocation.complex_cases).to be_empty
        end
      end

      context 'when omitting complex_cases attribute' do
        let(:data) do
          {
            type: 'allocations',
            attributes: allocation_attributes.except(:complex_cases),
            relationships: {
              from_location: { data: { type: 'locations', id: from_location.id } },
              to_location: { data: { type: 'locations', id: to_location.id } },
            },
          }
        end

        it 'creates an allocation without complex cases' do
          expect(allocation.complex_cases).to be_empty
        end
      end
    end

    context 'with a bad request' do
      let(:data) { nil }

      it_behaves_like 'an endpoint that responds with error 400'
    end

    context 'with a reference to a missing relationship' do
      let(:from_location) { Location.new }
      let(:detail_404) { "Couldn't find Location without an ID" }

      it_behaves_like 'an endpoint that responds with error 404'
    end

    context 'with validation errors' do
      let(:allocation_attributes) { attributes_for(:allocation).except(:date) }

      let(:errors_422) do
        [
          {
            'title' => 'Unprocessable entity',
            'detail' => "Date can't be blank",
            'source' => { 'pointer' => '/data/attributes/date' },
            'code' => 'blank',
          },
        ]
      end

      it_behaves_like 'an endpoint that responds with error 422'
    end
  end
end
