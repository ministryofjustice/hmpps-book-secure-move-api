# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::PeopleController do
  let(:token) { create(:access_token) }

  context 'when person is present ' do
    let!(:person) { create(:profile).person }

    it 'returns success' do
      get "/api/v1/people/#{person.id}/court_cases", params: { access_token: token.token }

      expect(response).to be_successful
    end
  end
end
