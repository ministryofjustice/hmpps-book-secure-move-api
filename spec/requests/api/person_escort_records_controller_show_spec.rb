# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::PersonEscortRecordsController do
  describe 'GET /person_escort_records/:person_escort_record_id' do
    include_context 'with supplier with spoofed access token'

    let(:response_json) { JSON.parse(response.body) }
    let(:framework_question) { build(:framework_question, section: 'risk-information') }
    let(:flag) { build(:framework_flag, framework_question:) }
    let(:framework) { create(:framework, framework_questions: [framework_question]) }
    let(:person_escort_record) do
      person_escort_record = create(:person_escort_record)
      create(:string_response, framework_question:, responded: true, framework_flags: [flag], assessmentable: person_escort_record)

      person_escort_record
    end
    let(:person_escort_record_id) { person_escort_record.id }

    before do
      person_escort_record.update_status_and_progress!
      get "/api/v1/person_escort_records/#{person_escort_record_id}?include=responses,flags", headers:, as: :json
    end

    context 'when successful' do
      let(:schema) { load_yaml_schema('get_person_escort_record_responses.yaml') }
      let(:data) do
        {
          "id": person_escort_record.id,
          "type": 'person_escort_records',
          "attributes": {
            "version": person_escort_record.framework.version,
            "completed_at": person_escort_record.completed_at.iso8601,
            "amended_at": nil,
            "status": 'completed',
          },
          "meta": {
            'section_progress' => [
              {
                "key": 'risk-information',
                "status": 'completed',
              },
            ],
          },
          "relationships": {
            "profile": {
              "data": {
                "id": person_escort_record.profile.id,
                "type": 'profiles',
              },
            },
            "framework": {
              "data": {
                "id": person_escort_record.framework.id,
                "type": 'frameworks',
              },
            },
            "responses": {
              "data": [
                {
                  "id": person_escort_record.framework_responses.first.id,
                  "type": 'framework_responses',
                },
              ],
            },
            "flags": {
              "data": [
                {
                  "id": flag.id,
                  "type": 'framework_flags',
                },
              ],
            },
          },
        }
      end

      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data:)
      end
    end

    context 'when unsuccessful' do
      let(:schema) { load_yaml_schema('error_responses.yaml') }

      context 'when attempting to access an unknown person escort record' do
        let(:person_escort_record_id) { SecureRandom.uuid }
        let(:detail_404) { "Couldn't find PersonEscortRecord with 'id'=#{person_escort_record_id}" }

        it_behaves_like 'an endpoint that responds with error 404'
      end
    end
  end
end
