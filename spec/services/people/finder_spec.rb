# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::Finder do
  subject(:people_finder) { described_class.new(filter_params) }

  let!(:person) { create(:person) }

  # create a second person with different IDs to check filters work properly
  before do
    create(:profile, profile_identifiers:
      [{ identifier_type: 'police_national_computer', value: 'CD/765432' },
       { identifier_type: 'prison_number', value: 'GFEDCBA' }])
  end

  describe 'filtering' do
    context 'when filtering by police_national_computer' do
      let(:filter_params) { { police_national_computer: 'AB/1234567' } }

      it 'returns people matching the police_national_computer' do
        expect(people_finder.call).to eq [person]
      end
    end

    context 'when filtering by prison_number' do
      let(:filter_params) { { prison_number: 'ABCDEFG' } }

      it 'returns people matching the prison_number' do
        expect(people_finder.call).to eq [person]
      end
    end
  end
end
