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
    context 'when matching police_national_computer filter' do
      let(:filter_params) { { police_national_computer: 'AB/1234567' } }

      it 'returns people matching the police_national_computer' do
        expect(people_finder.call).to eq [person]
      end
    end

    context 'when matching nomis_offender_no filter' do
      let(:filter_params) { { nomis_offender_no: 'ABCDEFG' } }

      it 'returns people matching the police_national_computer' do
        expect(people_finder.call).to eq [person]
      end
    end

    context 'when matching nomis_offender_no filter' do
      let(:filter_params) { { nomis_offender_no: 'ABCDEFG' } }

      it 'returns people matching the police_national_computer' do
        expect(people_finder.call.pluck(:id)).to eq [person.id]
      end
    end
  end
end
