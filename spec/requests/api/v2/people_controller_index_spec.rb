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
      before { get '/api/v2/people', params: params, headers: headers }

      it_behaves_like 'an endpoint that responds with success 200'

      xdescribe 'filtering results by police_national_computer' do
        let(:filters) do
          {
            bar: 'bar',
            police_national_computer: 'AB/1234567',
            foo: 'foo',
          }
        end
        let(:params) { { filter: filters } }
        let!(:person) { create(:person, :nomis_synced, police_national_computer: 'AB/1234567') }

        it 'filters the results' do
          expect(response_json['data'].size).to eq(1)
        end

        it 'returns the person that matches the filter' do
          expect(response_json).to include_json(data: [{ id: person.id }])
        end
      end

      xdescribe 'filtering results by criminal_records_office'
      xdescribe 'filtering results by prison_number'

      xdescribe 'paginating results' do
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
          expect(response_json['data'].size).to eq 20
        end

        it 'returns 1 result on the second page' do
          get '/api/v2/people?page=2', headers: headers

          expect(response_json['data'].size).to eq 1
        end

        it 'allows setting a different page size' do
          get '/api/v1/people?per_page=15', headers: headers

          expect(response_json['data'].size).to eq 15
        end

        it 'provides meta data with pagination' do
          get '/api/v2/people', headers: headers

          expect(response_json['meta']['pagination']).to include_json(meta_pagination)
        end
      end

      xdescribe 'included relationships' do
        let!(:people) { create_list :people, 2 }

        context 'when not including the include query param' do
          let(:params) { '' }

          it 'returns the default includes' do
            returned_types = response_json['included'].map { |r| r['type'] }.uniq
            expect(returned_types).to contain_exactly('people', 'moves', 'locations')
          end
        end

        context 'when including the include query param' do
          let(:params) { { include: ['foo.bar', 'from_location'] } }

          it 'returns the valid provided includes' do
            returned_types = response_json['included'].map { |r| r['type'] }.uniq
            expect(returned_types).to contain_exactly('locations')
          end
        end

        context 'when including an empty include query param' do
          let(:params) { { include: '' } }

          it 'returns none of the includes' do
            returned_types = response_json['included']
            expect(returned_types).to be_nil
          end
        end

        context 'when including a nil include query param' do
          let(:params) { { include: nil } }

          it 'returns the default includes' do
            returned_types = response_json['included'].map { |r| r['type'] }.uniq
            expect(returned_types).to contain_exactly('people', 'moves', 'locations')
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
