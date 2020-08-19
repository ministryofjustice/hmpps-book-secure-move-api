# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::ProfilesController do
  let(:response_json) { JSON.parse(response.body) }
  let(:access_token) { 'spoofed-token' }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }
  let(:person) { create(:person_without_profiles, prison_number: nil) }
  let(:risk_type_1) { create :assessment_question, :risk }
  let(:risk_type_2) { create :assessment_question, :risk }

  describe 'POST /v1/people/:id/profiles' do
    let(:schema) { load_yaml_schema('post_profiles_responses.yaml', version: 'v1') }

    let(:profile_params) do
      {
        data: {
          type: 'profiles',
          attributes: {
            assessment_answers: [],
          },
        },
      }
    end

    let(:expected_data) do
      {
        type: 'profiles',
        attributes: {
          assessment_answers: [],
        },
      }
    end

    context 'with valid params' do
      before { post "/api/v1/people/#{person.id}/profiles", params: profile_params, headers: headers, as: :json }

      it_behaves_like 'an endpoint that responds with success 201'

      it 'returns the correct data' do
        expect(response_json['data']).to include_json(expected_data)
      end

      it 'creates a new profile' do
        expect {
          post "/api/v1/people/#{person.id}/profiles", params: profile_params, headers: headers, as: :json
        }.to change(Profile, :count).by(1)
      end
    end

    # TODO: Mocking Nomis calls are broken and need fixing everywhere. We know these tests pass so are keeping this comment here
    describe 'updating assessment answers from Nomis' do
      let(:person) { create(:person_without_profiles, prison_number: prison_number) }
      let(:profile_params) do
        {
          data: {
            type: 'profiles',
            attributes: {},
          },
        }
      end

      context 'when the person has a prison_number' do
        let(:prison_number) { 'G5033UT' }

        before do
          allow(Profiles::ImportAlertsAndPersonalCareNeeds).to receive(:new)
                                            .and_return(instance_double('Profiles::ImportAlertsAndPersonalCareNeeds', call: true))

          post "/api/v1/people/#{person.id}/profiles", params: profile_params, headers: headers, as: :json
        end

        context 'when assessment_answers param is present' do
          let(:profile_params) do
            {
              data: {
                type: 'profiles',
                attributes: {
                  assessment_answers: [{ title: risk_type_1.title, assessment_question_id: risk_type_1.id }],
                },
              },
            }
          end

          it 'does NOT imports the assessment answers from Nomis' do
            expect(Profiles::ImportAlertsAndPersonalCareNeeds).not_to have_received(:new)
          end
        end

        context 'when assessment_answers param is NOT present' do
          let(:profile_params) do
            {
              data: {
                type: 'profiles',
                attributes: {},
              },
            }
          end

          it 'imports the assessment answers from Nomis' do
            expect(Profiles::ImportAlertsAndPersonalCareNeeds).to have_received(:new)
                                                                    .with(person.profiles.last, person.prison_number)
          end
        end
      end

      context 'when the person does NOT have a prison_number' do
        let(:prison_number) { nil }

        before do
          allow(Profiles::ImportAlertsAndPersonalCareNeeds).to receive(:new)
                                                                 .and_return(instance_double('Profiles::ImportAlertsAndPersonalCareNeeds'))

          post "/api/v1/people/#{person.id}/profiles", params: profile_params, headers: headers, as: :json
        end

        it 'does NOT import the assessment answers from Nomis' do
          expect(Profiles::ImportAlertsAndPersonalCareNeeds).not_to have_received(:new)
        end
      end
    end

    context 'with a person associated to multiple profiles' do
      it 'maintains previous profiles associated to the person' do
        person = create(:person, prison_number: nil)

        expect {
          post "/api/v1/people/#{person.id}/profiles", params: profile_params, headers: headers, as: :json
        }.to change(Profile, :count).from(1).to(2)
      end
    end

    context 'with included relationships' do
      let(:profile_params) do
        {
          include: include_params,
          data: {
            type: 'profiles',
            attributes: {
              assessment_answers: [
                { title: risk_type_1.title, assessment_question_id: risk_type_1.id },
                { title: risk_type_2.title, assessment_question_id: risk_type_2.id },
              ],
            },
          },
        }
      end

      before do
        post "/api/v1/people/#{person.id}/profiles", params: profile_params, headers: headers, as: :json
      end

      context 'when the include query param is empty' do
        let(:include_params) { [] }

        it 'does not include any relationship' do
          expect(response_json).not_to include('included')
        end
      end

      context 'when include is nil' do
        let(:include_params) { nil }

        it 'does not include any relationship' do
          expect(response_json).not_to include('included')
        end
      end

      context 'when including a relationship' do
        let(:include_params) { 'person' }

        it 'includes the relevant relationships' do
          returned_types = response_json['included'].map { |r| r['type'] }.uniq

          expect(returned_types).to contain_exactly('people')
        end
      end

      context 'when including a non existing relationship in a query param' do
        let(:include_params) { 'person,non-existent-relationship' }

        it 'responds with error 400' do
          response_error = response_json['errors'].first

          expect(response_error['title']).to eq('Bad request')
          expect(response_error['detail']).to include('["non-existent-relationship"] is not supported.')
        end
      end
    end

    context 'with a bad request' do
      before { post "/api/v1/people/#{person.id}/profiles", params: {}, headers: headers, as: :json }

      it_behaves_like 'an endpoint that responds with error 400'
    end

    context 'when the person_id is not found' do
      before { post '/api/v1/people/foo-bar/profiles', params: profile_params, headers: headers, as: :json }

      let(:detail_404) { "Couldn't find Person with 'id'=foo-bar" }

      it_behaves_like 'an endpoint that responds with error 404'
    end
  end
end
