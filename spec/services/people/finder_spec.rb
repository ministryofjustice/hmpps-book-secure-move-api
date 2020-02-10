# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::Finder do
  subject(:people_finder) { described_class.new(filter_params) }

  let!(:person) { create(:person) }
  let(:filter_params) { {} }

  describe 'filtering' do
    context 'when matching police_national_computer filter' do
      let(:filter_params) { { police_national_computer: 'AB/1234567' } }

      it 'returns people matching the police_national_computer' do
        expect(people_finder.call.pluck(:id)).to eq [person.id]
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
