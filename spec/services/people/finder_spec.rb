# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::Finder do
  subject(:people_finder) { described_class.new(filter_params) }

  let!(:person) { create(:person, police_national_computer: 'CD/765432', prison_number: 'GFEDCBA') }

  describe 'filtering' do
    context 'when filtering by police_national_computer' do
      let(:filter_params) { { police_national_computer: 'CD/765432' } }

      it 'returns people matching the police_national_computer' do
        expect(people_finder.call).to eq [person]
      end
    end

    context 'when filtering by empty police_national_computer' do
      let(:filter_params) { { police_national_computer: nil } }
      let!(:other_person) { create(:person, police_national_computer: nil, prison_number: 'GFEDCBA') }

      it 'returns people matching the police_national_computer' do
        expect(people_finder.call).to eq [other_person]
      end
    end

    context 'when filtering by prison_number' do
      let(:filter_params) { { prison_number: 'GFEDCBA' } }

      it 'returns people matching the prison_number' do
        expect(people_finder.call).to eq [person]
      end
    end

    context 'when filtering by empty prison_number' do
      let(:filter_params) { { prison_number: nil } }
      let!(:other_person) { create(:person, prison_number: nil) }

      it 'returns people matching the prison_number' do
        expect(people_finder.call).to eq [other_person]
      end
    end
  end
end
