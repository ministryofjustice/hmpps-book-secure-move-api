# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profiles::Finder do
  subject(:people_finder) { described_class.new(filter_params) }

  let!(:profile) { create(:profile) }
  let(:filter_params) { {} }

  describe 'filtering' do
    context 'when matching police_national_computer filter' do
      let(:filter_params) { { police_national_computer: 'AB/1234567' } }

      it 'returns people matching the police_national_computer' do
        expect(people_finder.call.pluck(:id)).to eq [profile.id]
      end
    end
  end
end
