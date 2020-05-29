# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V2::PeopleController do
  let(:supplier) { create(:supplier) }
  let!(:application) { create(:application, owner_id: supplier.id) }
  let!(:access_token) { create(:access_token, application: application).token }
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }
  let(:response_json) { JSON.parse(response.body) }
  let(:content_type) { ApiController::CONTENT_TYPE }

  describe 'GET /people' do
    let(:schema) { load_yaml_schema('get_people_responses.yaml', version: 'v2') }
    let!(:people) { create_list :person, 2 }
    let(:params) { {} }

    context 'when successful' do
      context 'when there are no params' do
        before { get '/api/v2/people', params: params, headers: headers }

        it_behaves_like 'an endpoint that responds with success 200'

        # TODO: think about this!
        it 'returns correct attributes' do
          expect(response_json['data'].first['attributes']).to include('last_name', 'first_names', 'date_of_birth', 'gender_additional_information')
        end

        it 'returns the correct number of people' do
          expect(response_json['data'].count).to eq(2)
        end
      end

      describe 'filtering results by police_national_computer' do
        let!(:person) { create(:person, police_national_computer: 'AB/1234567') }
        let(:filters) do
          {
            bar: 'bar',
            police_national_computer: 'AB/1234567',
            foo: 'foo',
          }
        end
        let(:params) { { filter: filters } }

        before { get '/api/v2/people', params: params, headers: headers }

        it 'returns the correct number of people' do
          expect(response_json['data'].size).to eq(1)
        end

        it 'returns the person that matches the filter' do
          expect(response_json).to include_json(data: [{ id: person.id }])
        end
      end

      describe 'filtering results by multiple filters' do
        let!(:person) do
          create(:person, criminal_records_office: 'CRO0105d', prison_number: 'D00001dZZ', police_national_computer: 'AB/00001d')
        end
        let(:filters) do
          {
            bar: 'bar',
            criminal_records_office: 'CRO0105d',
            police_national_computer: 'AB/00001d',
            prison_number: 'D00001dZZ',
            foo: 'foo',
          }
        end
        let(:params) { { filter: filters } }

        before { get '/api/v2/people', params: params, headers: headers }

        it 'returns the correct number of people' do
          expect(response_json['data'].size).to eq(1)
        end

        it 'returns the person that matches the filter' do
          expect(response_json).to include_json(data: [{ id: person.id }])
        end
      end

      xdescribe 'filtering results by multiple values per filter'

      describe 'paginating results' do
        let!(:people) { create_list :person, 21 }

        let(:meta_pagination) do
          {
            per_page: 20,
            total_pages: 2,
            total_objects: 21,
            links: {
              first: '/api/v2/people?page=1',
              last: '/api/v2/people?page=2',
              next: '/api/v2/people?page=2',
            },
          }
        end

        it 'paginates 20 results per page' do
          get '/api/v2/people?page=1', headers: headers

          expect(response_json['data'].size).to eq 20
        end

        it 'returns 1 result on the second page' do
          get '/api/v2/people?page=2', headers: headers

          expect(response_json['data'].size).to eq 1
        end

        it 'allows setting a different page size' do
          get '/api/v2/people?per_page=15', headers: headers

          expect(response_json['data'].size).to eq 15
        end

        it 'provides meta data with pagination' do
          get '/api/v2/people', headers: headers

          expect(response_json['meta']['pagination']).to include_json(meta_pagination)
        end
      end

      describe 'included relationships' do
        let!(:people) { create_list :person, 2 }

        before { get '/api/v2/people', params: params, headers: headers }

        context 'when the include query param is empty' do
          let(:params) { { include: [] } }

          it 'does not include any resource' do
            expect(response_json).not_to include('included')
          end
        end

        context 'when include is nil' do
          let(:params) { { include: nil } }

          it 'does not include any resource' do
            expect(response_json).not_to include('included')
          end
        end

        context 'when including the ethnicity query param' do
          let(:params) { { include: %w[ethnicity gender profiles] } }

          it 'returns the relevant ethnicity' do
            returned_types = response_json['included'].map { |r| r['type'] }.uniq

            expect(returned_types).to contain_exactly('ethnicities', 'genders', 'profiles')
          end
        end
      end
    end

    xcontext 'when not authorized', :with_invalid_auth_headers do
      let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
      let(:detail_401) { 'Token expired or invalid' }

      before do
        get '/api/v2/people', headers: headers
      end

      it_behaves_like 'an endpoint that responds with error 401'
    end

    xcontext 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      it_behaves_like 'an endpoint that responds with error 415'
    end
  end
end
