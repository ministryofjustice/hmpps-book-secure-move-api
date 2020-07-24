# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::PersonEscortRecordsController do
  describe 'PATCH /person_escort_records/:person_escort_record_id' do
    include_context 'with supplier with spoofed access token'

    let(:schema) { load_yaml_schema('patch_person_escort_record_responses.yaml') }
    let(:response_json) { JSON.parse(response.body) }
    let(:person_escort_record) { create(:person_escort_record, :with_responses, :completed) }
    let(:person_escort_record_id) { person_escort_record.id }
    let(:status) { 'confirmed' }
    let(:person_escort_record_params) do
      {
        data: {
          "type": 'person_escort_records',
          "attributes": {
            "status": status,
          },
        },
      }
    end

    before do
      patch "/api/v1/person_escort_records/#{person_escort_record_id}", params: person_escort_record_params, headers: headers, as: :json
      person_escort_record.reload
    end

    context 'when successful' do
      context 'when status is confirmed' do
        it_behaves_like 'an endpoint that responds with success 200'

        it 'returns the correct data' do
          expect(response_json).to include_json(data: {
            "id": person_escort_record_id,
            "type": 'person_escort_records',
            "attributes": {
              "status": 'confirmed',
              "version": person_escort_record.framework.version,
              "confirmed_at": person_escort_record.confirmed_at.iso8601,
              "printed_at": nil,
            },
          })
        end
      end

      context 'when status is printed' do
        let(:person_escort_record) { create(:person_escort_record, :with_responses, :confirmed) }
        let(:status) { 'printed' }

        it_behaves_like 'an endpoint that responds with success 200'

        it 'returns the correct data' do
          expect(response_json).to include_json(data: {
            "id": person_escort_record_id,
            "type": 'person_escort_records',
            "attributes": {
              "status": 'printed',
              "version": person_escort_record.framework.version,
              "printed_at": person_escort_record.printed_at.iso8601,
              "confirmed_at": person_escort_record.confirmed_at.iso8601,
            },
          })
        end
      end
    end

    context 'when unsuccessful' do
      context 'with a bad request' do
        let(:person_escort_record_params) { nil }

        it_behaves_like 'an endpoint that responds with error 400'
      end

      context 'with an invalid status' do
        let(:status) { 'foo-bar' }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [{ 'title' => 'Invalid status',
               'detail' => 'Validation failed: Status is not included in the list' }]
          end
        end
      end

      context 'when person_escort_record is wrong starting status' do
        let(:person_escort_record) { create(:person_escort_record, :with_responses, :in_progress) }

        it_behaves_like 'an endpoint that responds with error 422' do
          let(:errors_422) do
            [{ 'title' => 'Invalid state',
               'detail' => "Validation failed: State can't update to 'confirmed' from 'in_progress'" }]
          end
        end
      end

      context 'when the person_escort_record_id is not found' do
        let(:person_escort_record_id) { 'foo-bar' }
        let(:detail_404) { "Couldn't find PersonEscortRecord with 'id'=foo-bar" }

        it_behaves_like 'an endpoint that responds with error 404'
      end
    end
  end
end
