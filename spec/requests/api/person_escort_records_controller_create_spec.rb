# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::PersonEscortRecordsController do
  describe 'POST /person_escort_records' do
    include_context 'with supplier with spoofed access token'

    let(:response_json) { JSON.parse(response.body) }
    let(:profile) { create(:profile) }
    let(:profile_id) { profile.id }
    let(:framework) { create(:framework, framework_questions: [build(:framework_question, section: 'risk-information')]) }
    let(:framework_version) { framework.version }

    let(:person_escort_record_params) do
      {
        data: {
          "type": 'person_escort_records',
          "attributes": {
            "version": framework_version,
          },
          "relationships": {
            "profile": {
              "data": {
                "id": profile_id,
                "type": 'profiles',
              },
            },
          },
        },
      }
    end

    before do
      post '/api/v1/person_escort_records', params: person_escort_record_params, headers: headers, as: :json
    end

    context 'when successful' do
      let(:schema) { load_yaml_schema('post_person_escort_record_responses.yaml') }
      let(:data) do
        {
          "id": PersonEscortRecord.last.id,
          "type": 'person_escort_records',
          "attributes": {
            "version": framework_version,
            "status": 'not_started',
            "confirmed_at": nil,
          },
          "meta": {
            'section_progress' => [
              {
                "key": 'risk-information',
                "status": 'not_started',
              },
            ],
          },
          "relationships": {
            "profile": {
              "data": {
                "id": profile_id,
                "type": 'profiles',
              },
            },
            "framework": {
              "data": {
                "id": framework.id,
                "type": 'frameworks',
              },
            },
            "responses": {
              "data": [
                {
                  "id": FrameworkResponse.last.id,
                  "type": 'framework_responses',
                },
              ],
            },
            "flags": {
              "data": [],
            },
          },
        }
      end

      it_behaves_like 'an endpoint that responds with success 201'

      it 'returns the correct data' do
        expect(response_json).to include_json(data: data)
      end
    end

    context 'when unsuccessful' do
      let(:schema) { load_yaml_schema('error_responses.yaml') }

      context 'with a bad request' do
        let(:person_escort_record_params) { nil }

        it_behaves_like 'an endpoint that responds with error 400'
      end

      context 'when the profile is not found' do
        let(:profile_id) { 'foo-bar' }
        let(:detail_404) { "Couldn't find Profile with 'id'=foo-bar" }

        it_behaves_like 'an endpoint that responds with error 404'
      end

      context 'with a reference to a missing framework' do
        let(:framework_version) { '0.2.1' }
        let(:detail_404) { "Couldn't find Framework" }

        it_behaves_like 'an endpoint that responds with error 404'
      end

      context 'with no framework' do
        let(:person_escort_record_params) do
          {
            data: {
              "type": 'person_escort_records',
              "relationships": {
                "profile": {
                  "data": {
                    "id": profile_id,
                    "type": 'profiles',
                  },
                },
              },
            },
          }
        end
        let(:detail_404) { "Couldn't find Framework" }

        it_behaves_like 'an endpoint that responds with error 404'
      end
    end
  end
end
