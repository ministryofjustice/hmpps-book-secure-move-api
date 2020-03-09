# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::PeopleController do
  let!(:token) { create(:access_token) }
  let(:response_json) { JSON.parse(response.body) }
  let(:image_urls) { response_json['data'].map { |x| x['attributes']['image_url'] } }

  let(:schema) { load_json_schema('get_people_responses.json') }

  describe 'GET /people' do
    let(:prison_number) { 'G5033UT' }

    describe 'filtering the results' do
      let(:params) { { filter: { police_national_computer: 'AB/1234567' }, access_token: token.token } }

      context 'when called with police_national_computer filter' do
        let!(:people) { create_list :person, 5, :nomis_synced }

        before do
          get '/api/v1/people', headers: headers, params: params
        end

        it_behaves_like 'an endpoint that responds with success 200'

        it 'returns the correct data' do
          expect(response_json['data'].size).to eq(5)
        end

        it 'returns an image URL' do
          expect(image_urls).
            to match_array(people.map { |p| "http://localhost:4000/api/v1/people/#{p.id}/image" })
        end
      end

      context 'with no ethnicity' do
        let!(:person) { create(:profile, ethnicity: nil).person }

        before do
          get '/api/v1/people', headers: headers, params: params
        end

        it_behaves_like 'an endpoint that responds with success 200'
      end

      it 'delegates the query execution to People::Finder with correct filter', skip_before: true do
        people_finder = instance_double('People::Finder', call: Person.all)
        allow(People::Finder).to receive(:new).and_return(people_finder)

        get '/api/v1/people', headers: headers, params: params

        expect(People::Finder).to have_received(:new).with(police_national_computer: 'AB/1234567')
      end
    end

    context 'when the filter prison_number is used' do
      let!(:people) { create_list :person, 5 }

      let(:params) { { filter: { prison_number: prison_number }, access_token: token.token } }
      let(:people_finder) { instance_double('People::Finder', call: Person.all) }

      before do
        allow(People::Finder).to receive(:new).and_return(people_finder)
        allow(Moves::ImportPeople).to receive(:new).with([person_nomis_prison_number: prison_number])
                                                   .and_return(instance_double('Moves::ImportPeople', call: nil))
        get '/api/v1/people', headers: headers, params: params
      end

      it 'doesnt returns any image URLs' do
        expect(image_urls).to eq([nil] * 5)
      end

      it 'requests data from NOMIS', with_json_schema: true do
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
