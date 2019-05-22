# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProfileAttributeTypes::Finder do
  subject(:finder) { described_class.new(filter_params) }

  let!(:profile_attribute_type) { create :profile_attribute_type }
  let(:id) { profile_attribute_type.id }
  let(:filter_params) { {} }

  describe 'filtering' do
    context 'with matching `user_type` filter' do
      let(:filter_params) { { user_type: profile_attribute_type.user_type } }

      it 'returns profile attribute type matching `user_type`' do
        expect(finder.call.pluck(:id)).to eql [profile_attribute_type.id]
      end
    end

    context 'with mis-matching `user_type` filter' do
      let(:filter_params) { { user_type: 'not a user type' } }

      it 'returns empty result set' do
        expect(finder.call.to_a).to eql []
      end
    end

    context 'with matching `category` filter' do
      let(:filter_params) { { category: profile_attribute_type.category } }

      it 'returns profile attribute type matching `category`' do
        expect(finder.call.pluck(:id)).to eql [profile_attribute_type.id]
      end
    end

    context 'with mis-matching `category` filter' do
      let(:filter_params) { { category: 'not a category' } }

      it 'returns empty result set' do
        expect(finder.call.to_a).to eql []
      end
    end
  end
end
