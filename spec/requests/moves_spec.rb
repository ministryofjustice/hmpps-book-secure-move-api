# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Moves', type: :request do
  describe 'GET /moves' do
    context 'when there is no data' do
      it 'returns an empty list' do
        get '/moves'
        expect(JSON.parse(response.body)).to eql []
      end

      it 'only works if I set the right `application` header'
    end
  end
end
