# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::PeopleController do
  let(:response_json) { JSON.parse(response.body) }
  let(:access_token) { 'spoofed-token' }
  let(:content_type) { ApiController::CONTENT_TYPE }

  let(:headers) do
    {
      'CONTENT_TYPE': content_type,
      'Accept': 'application/vnd.api+json; version=2',
      'Authorization' => "Bearer #{access_token}",
    }
  end

  describe 'PATCH /api/people' do
    let(:schema) { load_yaml_schema('patch_people_responses.yaml', version: 'v2') }

    let(:person) { create :person }
    let(:ethnicity_id) { create(:ethnicity).id }
    let(:gender_id) { create(:gender).id }

    let(:person_params) do
      {
        data: {
          type: 'people',
          attributes: {
            first_names: 'Bob',
            last_name: 'Roberts',
            date_of_birth: Date.new(1980, 1, 1),
            prison_number: 'G3239GV',
            criminal_records_office: 'CRO0111d',
            police_national_computer: person.police_national_computer,
            gender_additional_information: 'info about Bob',
          },
          relationships: {
            ethnicity: {
              data: {
                id: ethnicity_id,
                type: 'ethnicities',
              },
            },
            gender: {
              data: {
                id: gender_id,
                type: 'genders',
              },
            },
          },
        },
      }
    end

    let(:expected_data) do
      {
        type: 'people',
        attributes: {
          first_names: 'Bob',
          last_name: 'Roberts',
          date_of_birth: '1980-01-01',
          prison_number: 'G3239GV',
          criminal_records_office: 'CRO0111d',
          police_national_computer: person.police_national_computer,
          gender_additional_information: 'info about Bob',
        },
        relationships: {
          gender: {
            data: {
              type: 'genders',
              id: gender_id,
            },
          },
          ethnicity: {
            data: {
              type: 'ethnicities',
              id: ethnicity_id,
            },
          },
        },
      }
    end

    let(:expected_included) do
      []
    end

    context 'with valid params' do
      before { patch "/api/people/#{person.id}", params: person_params, headers: headers, as: :json }

      it_behaves_like 'an endpoint that responds with success 200'
    end

    it 'returns the correct data' do
      patch "/api/people/#{person.id}", params: person_params, headers: headers, as: :json

      expect(response_json).to include_json(data: expected_data.merge(id: person.id))
    end

    context 'when gender relationship is not supplied' do
      let(:person_params) do
        {
          data: {
            type: 'people',
            relationships: {
              ethnicity: { data: { id: ethnicity_id, type: 'ethnicities' } },
            },
          },
        }
      end

      it 'does not change the gender' do
        expect { patch "/api/people/#{person.id}", params: person_params, headers: headers, as: :json }
          .not_to(change { person.reload.gender_id })
      end
    end

    context 'when relationships are supplied but are specified as nil' do
      let(:person_params) do
        {
          data: {
            type: 'people',
            relationships: { ethnicity: { data: nil } },
          },
        }
      end

      it 'sets the ethnicity to nil' do
        expect { patch "/api/people/#{person.id}", params: person_params, headers: headers, as: :json }
          .to change { person.reload.ethnicity_id }.to(nil)
      end
    end

    describe 'include query param' do
      before do
        patch "/api/people/#{person.id}#{query_params}", params: person_params, headers: headers, as: :json
      end

      context 'when including multiple relationships' do
        let(:query_params) { '?include=gender,ethnicity,profiles' }

        it 'includes the correct relationships' do
          expect(response_json['included'].count).to eq(3)
          expect(response_json['included']).to include_json(UnorderedArray({ type: 'ethnicities' }, { type: 'genders' }, { type: 'profiles' }))
        end
      end

      context 'when does NOT include any relationship' do
        let(:query_params) { '' }

        it 'does NOT include any relationships' do
          expect(response_json).not_to include('included')
        end
      end

      context 'when including a non existing relationship' do
        let(:query_params) { '?include=gender,non-existent-relationship' }

        it 'responds with error 400' do
          response_error = response_json['errors'].first

          expect(response_error['title']).to eq('Bad request')
          expect(response_error['detail']).to include('["non-existent-relationship"] is not supported.')
        end
      end
    end

    describe 'webhook and email notifications' do
      before do
        allow(Notifier).to receive(:prepare_notifications)
        patch "/api/people/#{person.id}", params: person_params, headers: headers, as: :json
      end

      it 'calls the notifier when updating a person' do
        expect(Notifier).to have_received(:prepare_notifications).with(topic: person, action_name: 'update')
      end
    end

    context 'with a bad request' do
      before { patch "/api/people/#{person.id}", params: {}, headers: headers, as: :json }

      it_behaves_like 'an endpoint that responds with error 400'
    end
  end
end
