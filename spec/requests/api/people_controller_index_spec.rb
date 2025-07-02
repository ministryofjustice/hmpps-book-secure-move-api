# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::PeopleController do
  subject(:get_people) { get '/api/v1/people', headers:, params: }

  let(:access_token) { 'spoofed-token' }
  let(:headers) { { 'CONTENT_TYPE': content_type, 'Authorization': "Bearer #{access_token}" } }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }

  let(:schema) { load_yaml_schema('get_people_responses.yaml') }

  describe 'GET /v1/people' do
    let(:params) {}

    let(:prison_number) { 'G5033UT' }

    context 'when called with NO filters' do
      let(:params) {}

      before do
        create_list :person, 2
        get_people
      end

      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json['data'].size).to eq(2)
      end
    end

    context 'when called with an array of filters' do
      let(:params) { { filter: %w[a] } }

      before { get_people }

      it_behaves_like 'an endpoint that responds with success 200'
    end

    context 'when called with police_national_computer filter' do
      let(:params) { { filter: { police_national_computer: 'AB/1234567' } } }

      before { create_list :person, 5, :nomis_synced, police_national_computer: 'AB/1234567' }

      it 'returns the correct data' do
        get_people

        expect(response_json['data'].size).to eq(5)
      end

      it 'delegates the query execution to People::Finder with correct filter', :skip_before do
        people_finder = instance_double(People::Finder, call: Person.all)
        allow(People::Finder).to receive(:new).and_return(people_finder)

        get_people

        expect(People::Finder).to have_received(:new).with(police_national_computer: 'AB/1234567')
      end
    end

    context 'with no ethnicity' do
      before do
        create(:person, ethnicity: nil)
        get_people
      end

      it_behaves_like 'an endpoint that responds with success 200'
    end

    context 'when the filter prison_number is used' do
      let(:gender) { create(:gender) }
      let(:ethnicity) { create(:ethnicity) }

      let(:params) { { filter: { prison_number: } } }
      let(:people_finder) { instance_double(People::Finder, call: Person.all) }

      before { create_list :person, 5, gender:, ethnicity: }

      context 'when Nomis replies with success' do
        before do
          allow(People::Finder).to receive(:new).and_return(people_finder)
          allow(Moves::ImportPeople).to receive(:new).with([prison_number.upcase])
                                            .and_return(instance_double(Moves::ImportPeople, call: nil))
          get_people
        end

        it 'requests data from NOMIS' do
          expect(response).to have_http_status(:ok)
        end

        context 'when the prison_number is downcased' do
          let(:params) { { filter: { prison_number: prison_number.downcase } } }

          it 'requests data from NOMIS' do
            expect(response).to have_http_status(:ok)
          end
        end
      end

      context 'when the Prisoner Search API times out' do
        it 'returns 5xx error for API timeout' do
          allow(PrisonerSearchApiClient::Prisoner).to receive(:get).and_raise(Faraday::TimeoutError)
          get_people
          expect(response.status).to be_in([502, 503])
        end
      end
    end

    describe 'included relationships' do
      before do
        create_list :person, 2, police_national_computer: 'AB/1234567'
        get "/api/v1/people#{query_params}", headers:, params:
      end

      context 'when not including the include query param' do
        let(:query_params) { '' }

        it 'returns the default includes' do
          returned_types = response_json['included'].map { |r| r['type'] }.uniq
          expect(returned_types).to contain_exactly('ethnicities', 'genders')
        end
      end

      context 'when including the include query param' do
        let(:query_params) { '?include=gender' }

        it 'returns the valid provided includes' do
          returned_types = response_json['included'].map { |r| r['type'] }.uniq
          expect(returned_types).to contain_exactly('genders')
        end
      end

      context 'when including an invalid include query param' do
        let(:query_params) { '?include=foo.bar,gender' }

        let(:expected_error) do
          {
            'errors' => [
              {
                'title' => 'Bad request',
                'detail' => '["foo.bar"] is not supported. Valid values are: ["ethnicity", "gender"]',
              },
            ],
          }
        end

        it 'returns a validation error' do
          expect(response).to have_http_status(:bad_request)
          expect(response_json).to eq(expected_error)
        end
      end

      context 'when including an empty include query param' do
        let(:query_params) { '?include=' }

        it 'returns none of the includes' do
          returned_types = response_json['included']
          expect(returned_types).to be_nil
        end
      end

      context 'when including a nil include query param' do
        let(:query_params) { '?include' }

        it 'returns the default includes' do
          returned_types = response_json['included'].map { |r| r['type'] }.uniq

          expect(returned_types).to contain_exactly('ethnicities', 'genders')
        end
      end
    end
  end
end
