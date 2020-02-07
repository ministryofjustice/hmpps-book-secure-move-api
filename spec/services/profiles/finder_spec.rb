# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profiles::Finder do
  subject(:profile_finder) { described_class.new(filter_params) }

  let!(:profile) { create(:profile) }
  let(:filter_params) { {} }

  describe 'filtering' do
    context 'when matching police_national_computer filter' do
      let(:filter_params) { { police_national_computer: 'AB/1234567' } }

      it 'returns people matching the police_national_computer' do
        expect(profile_finder.call).to eq [profile]
      end
    end
  end
end
