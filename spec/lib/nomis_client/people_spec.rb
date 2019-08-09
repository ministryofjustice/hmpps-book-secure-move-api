# frozen_string_literal: true

require 'rails_helper'
require 'dotenv/load'

RSpec.describe NomisClient::People do
  describe '.get' do
    let(:response) { described_class.get }

    it 'has the correct number of results' do
      VCR.use_cassette('people', record: :new_episodes) do
        expect(response.count).to be 1
      end
    end
  end
end
