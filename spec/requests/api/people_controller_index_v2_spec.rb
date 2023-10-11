# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::PeopleController do
  let(:access_token) { 'spoofed-token' }
  let(:response_json) { JSON.parse(response.body) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:headers) do
    {
      'CONTENT_TYPE': content_type,
      'Accept': 'application/vnd.api+json; version=2',
      'Authorization' => "Bearer #{access_token}",
    }
  end

  describe 'GET /people' do
    let(:schema) { load_yaml_schema('get_people_responses.yaml', version: 'v2') }

    before { create_list :person, 2, prison_number: nil }

    context 'when the API client requires compressed response' do
      let(:accept_encoding) { 'gzip, deflate' }

      it 'returns compressed response' do
        get '/api/people', headers: headers.merge('Accept-Encoding' => accept_encoding)

        expect(response.headers['Content-Encoding']).to be 'gzip'
      end
    end

    context 'when the API client does NOT require compressions' do
      it 'returns non compressed response' do
        get('/api/people', headers:)

        expect(response.headers['Content-Encoding']).to be nil
      end
    end

    context 'when there are no filters' do
      let(:params) { {} }

      before { get '/api/people', params:, headers: }

      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns correct attributes' do
        expect(response_json['data'].first['attributes']).to include(
          'first_names',
          'last_name',
          'date_of_birth',
          'gender_additional_information',
          'prison_number',
          'criminal_records_office',
          'police_national_computer',
        )
      end

      it 'returns the correct number of people' do
        expect(response_json['data'].count).to eq(2)
      end
    end

    context 'when prison_numbers is present in query' do
      let(:query) { '?filter[prison_number]=G3239GV,GV345VG' }
      let(:import_from_nomis) { instance_double('People::ImportFromNomis', call: nil) }

      before do
        create(:person, prison_number: 'G3239GV')
        create(:person, prison_number: 'GV345VG')
        create(:person, prison_number: 'FLIBBLE')

        allow(People::ImportFromNomis).to receive(:new).and_return(import_from_nomis)
      end

      it 'updates the person from nomis' do
        get("/api/people#{query}", headers:)

        expect(People::ImportFromNomis).to have_received(:new).with(%w[G3239GV GV345VG])
        expect(import_from_nomis).to have_received(:call)
      end

      it 'returns the correct people' do
        get("/api/people#{query}", headers:)

        prison_numbers = response_json['data'].map { |resource| resource.dig('attributes', 'prison_number') }
        expect(prison_numbers).to match_array(%w[G3239GV GV345VG])
      end

      context 'when the prison_number is downcased' do
        let(:query) { '?filter[prison_number]=g3239gv,gv345vg' }

        it 'updates the person from nomis' do
          get("/api/people#{query}", headers:)

          expect(People::ImportFromNomis).to have_received(:new).with(%w[G3239GV GV345VG])
          expect(import_from_nomis).to have_received(:call)
        end

        it 'returns the correct people' do
          get("/api/people#{query}", headers:)

          prison_numbers = response_json['data'].map { |resource| resource.dig('attributes', 'prison_number') }
          expect(prison_numbers).to match_array(%w[G3239GV GV345VG])
        end
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

      before { get '/api/people', params:, headers: }

      it 'returns the correct number of people' do
        expect(response_json['data'].size).to eq(1)
      end

      it 'returns the person that matches the filter' do
        expect(response_json).to include_json(data: [{ id: person.id }])
      end
    end

    describe 'filtering results by multiple filters' do
      let!(:person) do
        create(:person, criminal_records_office: 'CRO0105d', police_national_computer: 'AB/00001d')
      end
      let(:filters) do
        {
          bar: 'bar',
          criminal_records_office: 'CRO0105d',
          police_national_computer: 'AB/00001d',
          foo: 'foo',
        }
      end
      let(:params) { { filter: filters } }

      before { get '/api/people', params:, headers: }

      it 'returns the correct number of people' do
        expect(response_json['data'].size).to eq(1)
      end

      it 'returns the person that matches the filter' do
        expect(response_json).to include_json(data: [{ id: person.id }])
      end
    end

    describe 'filtering results by multiple values per filter'  do
      let!(:person1) { create(:person, criminal_records_office: 'CRO0111d') }
      let!(:person2) { create(:person, criminal_records_office: 'CRO0222d') }
      let(:filters) do
        {
          criminal_records_office: 'CRO0111d,CRO0222d',
        }
      end
      let(:params) { { filter: filters } }

      before { get '/api/people', params:, headers: }

      it 'returns the correct number of people' do
        expect(response_json['data'].size).to eq(2)
      end

      it 'returns the person that matches the filter' do
        expect(response_json).to include_json(data: [{ id: person1.id }, { id: person2.id }])
      end
    end

    describe 'paginating results' do
      let(:params) { {} }

      let(:meta_pagination) do
        {
          per_page: 5,
          total_pages: 2,
          total_objects: 6,
        }
      end
      let(:pagination_links) do
        {
          self: 'http://www.example.com/api/people?page=1&per_page=5',
          first: 'http://www.example.com/api/people?page=1&per_page=5',
          prev: nil,
          next: 'http://www.example.com/api/people?page=2&per_page=5',
          last: 'http://www.example.com/api/people?page=2&per_page=5',
        }
      end

      before do
        create_list :person, 4
        get '/api/people', params:, headers:
      end

      it_behaves_like 'an endpoint that paginates resources'
    end

    describe 'included relationships' do
      before do
        create_list :person, 2
        get '/api/people', params:, headers:
      end

      context 'when the include query param is empty' do
        let(:params) { { include: [] } }

        it 'does not include any relationship' do
          expect(response_json).not_to include('included')
        end
      end

      context 'when include is nil' do
        let(:params) { { include: nil } }

        it 'does not include any relationship' do
          expect(response_json).not_to include('included')
        end
      end

      context 'when including multiple relationships' do
        let(:params) { { include: 'ethnicity,gender,profiles' } }

        it 'includes the relevant relationships' do
          returned_types = response_json['included'].map { |r| r['type'] }.uniq

          expect(returned_types).to contain_exactly('ethnicities', 'genders', 'profiles')
        end
      end

      context 'when including a non existing relationship in a query param' do
        let(:params) { { include: 'gender,non-existent-relationship' } }

        it 'responds with error 400' do
          response_error = response_json['errors'].first

          expect(response_error['title']).to eq('Bad request')
          expect(response_error['detail']).to include('["non-existent-relationship"] is not supported.')
        end
      end
    end
  end
end
