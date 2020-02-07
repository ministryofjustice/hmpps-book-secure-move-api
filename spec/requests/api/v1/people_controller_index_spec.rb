# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::PeopleController, with_client_authentication: true do
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }

  describe 'GET /people' do
    let(:schema) { load_json_schema('get_people_responses.json') }

    let!(:people) { create_list :person, 5 }

    describe 'filtering the results' do
      let(:params) { { filter: { police_national_computer: 'AB/1234567' } } }

      context 'when called with police_national_computer filter' do
        before do
          get '/api/v1/people', headers: headers, params: params
        end

        it_behaves_like 'an endpoint that responds with success 200'
      end

      it 'delegates the query execution to Profiles::Finder with correct filter', skip_before: true do
        profile_finder = instance_double('Profiles::Finder', call: Profile.all)
        allow(Profiles::Finder).to receive(:new).and_return(profile_finder)

        get '/api/v1/people', headers: headers, params: params

        expect(Profiles::Finder).to have_received(:new).with(police_national_computer: 'AB/1234567')
      end
    end
  end
end
