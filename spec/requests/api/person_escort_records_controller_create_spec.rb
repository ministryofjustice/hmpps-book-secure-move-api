# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Api::PersonEscortRecordsController do
  describe 'POST /person_escort_records' do
    subject(:post_person_escort_record) do
      post '/api/v1/person_escort_records', params: person_escort_record_params, headers: headers, as: :json
    end

    include_context 'with supplier with spoofed access token'

    let(:response_json) { JSON.parse(response.body) }
    let(:person) { create(:person) }
    let(:profile) { create(:profile, person: person) }
    let(:profile_id) { profile.id }
    let(:move) { create(:move, profile: profile) }
    let(:move_id) { move.id }
    let(:framework) { create(:framework, framework_questions: [build(:framework_question, section: 'risk-information', prefill: true)]) }
    let(:framework_version) { framework.version }

    let(:person_escort_record_params) do
      {
        data: {
          "type": 'person_escort_records',
          "attributes": {
            "version": framework_version,
          },
          "relationships": {
            "move": {
              "data": {
                "id": move_id,
                "type": 'moves',
              },
            },
          },
        },
        include: 'responses,flags',
      }
    end

    before { post_person_escort_record }

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
            "nomis_sync_status": [],
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
            "move": {
              "data": {
                "id": move_id,
                "type": 'moves',
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
            "prefill_source": {
              "data": nil,
            },
          },
        }
      end

      it_behaves_like 'an endpoint that responds with success 201'

      it 'returns the correct data' do
        expect(response_json).to include_json(data: data)
      end
    end

    context 'when prefilling from previous person escort record' do
      subject(:post_person_escort_record) do
        previous_pesron_escort_record

        post '/api/v1/person_escort_records', params: person_escort_record_params, headers: headers, as: :json
      end

      let(:previous_profile) { create(:profile, person: person) }
      let(:previous_pesron_escort_record) do
        create(:person_escort_record, :confirmed, profile: previous_profile, framework_responses: [create(:string_response, framework_question: framework.framework_questions.first)])
      end
      let(:person_escort_record_params) do
        {
          data: {
            "type": 'person_escort_records',
            "attributes": {
              "version": framework_version,
            },
            "relationships": {
              "move": {
                "data": {
                  "id": move_id,
                  "type": 'moves',
                },
              },
            },
          },
          include: 'responses,flags',
        }
      end
      let(:schema) { load_yaml_schema('post_person_escort_record_responses.yaml') }
      let(:new_person_escort_record) { PersonEscortRecord.order(created_at: :desc).first }
      let(:data) do
        {
          "id": new_person_escort_record.id,
          "type": 'person_escort_records',
          "attributes": {
            "version": framework_version,
            "status": 'not_started',
            "confirmed_at": nil,
            "nomis_sync_status": [],
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
            "move": {
              "data": {
                "id": move_id,
                "type": 'moves',
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
                  "id": new_person_escort_record.reload.framework_responses.last.id,
                  "type": 'framework_responses',
                },
              ],
            },
            "flags": {
              "data": [],
            },
            "prefill_source": {
              "data": {
                "id": previous_pesron_escort_record.id,
                "type": 'person_escort_records',
              },
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

      context 'when the move is not found' do
        let(:move_id) { 'foo-bar' }
        let(:detail_404) { "Couldn't find Move with 'id'=foo-bar" }

        it_behaves_like 'an endpoint that responds with error 404'
      end

      context 'when a person escort record already exists on a profile' do
        let(:errors_422) do
          [
            {
              'title' => 'Unprocessable entity',
              'detail' => 'Profile has already been taken',
              'source' => { 'pointer' => '/data/attributes/profile' },
              'code' => 'taken',
            },
          ]
        end

        before do
          post '/api/v1/person_escort_records', params: person_escort_record_params, headers: headers, as: :json
          post '/api/v1/person_escort_records', params: person_escort_record_params, headers: headers, as: :json
        end

        it_behaves_like 'an endpoint that responds with error 422'
      end

      context 'when a person escort record already exists on a profile and unique index error thrown' do
        let(:errors_422) do
          [
            {
              'title' => 'Unprocessable entity',
              'detail' => 'Profile has already been taken',
              'source' => { 'pointer' => '/data/attributes/profile' },
              'code' => 'taken',
            },
          ]
        end

        before do
          person_escort_record = PersonEscortRecord.new
          allow(PersonEscortRecord).to receive(:new).and_return(person_escort_record)
          allow(person_escort_record).to receive(:build_responses!).and_raise(PG::UniqueViolation, 'duplicate key value violates unique constraint')

          post '/api/v1/person_escort_records', params: person_escort_record_params, headers: headers, as: :json
        end

        it_behaves_like 'an endpoint that responds with error 422'
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
                "move": {
                  "data": {
                    "id": move_id,
                    "type": 'moves',
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
# rubocop:enable RSpec/MultipleMemoizedHelpers
